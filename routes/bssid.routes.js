/**
 * File: bssid.routes.js
 *
 * Routes:
 * GET  /api              → Renders BSSID admin dashboard
 * POST /api/register     → Register room + BSSID (atomic)
 * POST /api/localize     → Resolve room from BSSID
 * POST /api/update-location → Update user location via BSSID (socket emit)
 * GET  /api/all-locations   → All users + current rooms
 * GET  /api/rooms           → All rooms list
 * POST /api/update-position → Update user x/z position (socket emit)
 */

import express from "express";
import pool from "../db/index.js";

const router = express.Router();

/* ==================================================
   GET: Render BSSID Dashboard
================================================== */
router.get("/api", (req, res) => {
  res.render("bssidDashboard");
});

/* ==================================================
   POST: Register Room + BSSID
   FIX: Atomic INSERT … ON CONFLICT to eliminate
        the race condition from a separate SELECT+INSERT.
================================================== */
router.post("/api/register", async (req, res) => {
  const { room_name, bssid, band, ssid_name } = req.body;

  if (!room_name || !bssid) {
    return res.status(400).json({
      success: false,
      message: "room_name and bssid are required"
    });
  }

  try {
    /* Atomically upsert the room — no race condition */
    let roomId;
    const upsertRoom = await pool.query(
      `INSERT INTO rooms (room_name)
       VALUES ($1)
       ON CONFLICT (room_name) DO NOTHING
       RETURNING id`,
      [room_name]
    );

    if (upsertRoom.rows.length > 0) {
      roomId = upsertRoom.rows[0].id;
    } else {
      /* Room already existed — fetch its id */
      const existing = await pool.query(
        "SELECT id FROM rooms WHERE room_name = $1",
        [room_name]
      );
      roomId = existing.rows[0].id;
    }

    /* Insert BSSID mapping */
    await pool.query(
      `INSERT INTO room_bssids (room_id, bssid, band, ssid_name)
       VALUES ($1, $2, $3, $4)`,
      [roomId, bssid, band || null, ssid_name || null]
    );

    return res.json({
      success: true,
      message: "Room and BSSID stored successfully"
    });

  } catch (err) {
    console.error("DB ERROR /api/register:", err.message);

    if (err.code === "23505") {
      return res.status(409).json({
        success: false,
        message: "BSSID already registered"
      });
    }

    return res.status(500).json({
      success: false,
      message: "Internal server error"
    });
  }
});

/* ==================================================
   POST: Localize Room using BSSID
   FIX: Return 404 (not 200) when no room is found.
================================================== */
router.post("/api/localize", async (req, res) => {
  const { bssid } = req.body;

  if (!bssid) {
    return res.status(400).json({ success: false, message: "bssid is required" });
  }

  try {
    const result = await pool.query(
      `SELECT r.room_name
       FROM room_bssids rb
       JOIN rooms r ON rb.room_id = r.id
       WHERE rb.bssid = $1`,
      [bssid]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ found: false, message: "Room not found for this BSSID" });
    }

    return res.json({ found: true, room: result.rows[0].room_name });

  } catch (err) {
    console.error("DB ERROR /api/localize:", err.message);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
});

/* ==================================================
   POST: Update User Location
   - Resolves room from BSSID
   - Upserts user_locations row
   - Emits socket "location-update" event
================================================== */
router.post("/api/update-location", async (req, res) => {
  const { user_id, bssid } = req.body;

  if (!user_id || !bssid) {
    return res.status(400).json({
      success: false,
      message: "user_id and bssid are required"
    });
  }

  try {
    /* Step 1: Resolve room from BSSID */
    const roomResult = await pool.query(
      `SELECT rb.room_id, r.room_name, r.floor, r.building
       FROM room_bssids rb
       JOIN rooms r ON rb.room_id = r.id
       WHERE rb.bssid = $1`,
      [bssid]
    );

    if (roomResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No room mapped for this BSSID"
      });
    }

    const { room_id, room_name, floor, building } = roomResult.rows[0];

    /* Step 2: Upsert user location (insert or update on conflict) */
    await pool.query(
      `INSERT INTO user_locations (user_id, room_id, last_seen)
       VALUES ($1, $2, NOW())
       ON CONFLICT (user_id)
       DO UPDATE SET room_id = $2, last_seen = NOW()`,
      [user_id, room_id]
    );

    /* Step 2b: Append to history log (for timeline / heatmap) */
    await pool.query(
      `INSERT INTO location_history (user_id, room_id, entered_at)
       VALUES ($1, $2, NOW())`,
      [user_id, room_id]
    );

    /* Step 3: Push real-time update to all connected browser clients */
    const io = req.app.get("io");
    if (io) {
      io.emit("location-update", {
        user_id,
        room_name,
        floor,
        building,
        last_seen: new Date().toISOString(),   // always UTC ISO string with Z
      });
    }

    return res.json({
      success: true,
      message: "Location updated",
      room: room_name
    });

  } catch (err) {
    console.error("DB ERROR /api/update-location:", err.message);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
});

/* ==================================================
   GET: All User Locations
   Returns every user with their current room details.
   Used by the 2D and 2.5D map views.
================================================== */
router.get("/api/all-locations", async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT ul.user_id,
              r.room_name,
              r.floor,
              r.building,
              ul.x_pos,
              ul.z_pos,
              ul.last_seen
       FROM user_locations ul
       JOIN rooms r ON ul.room_id = r.id
       ORDER BY ul.last_seen DESC`
    );

    return res.json({
      success: true,
      count: result.rows.length,
      users: result.rows
    });

  } catch (err) {
    console.error("DB ERROR /api/all-locations:", err.message);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
});

/* ==================================================
   GET: All Rooms
================================================== */
router.get("/api/rooms", async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, room_name, floor, building
       FROM rooms
       ORDER BY room_name`
    );
    return res.json({ success: true, rooms: result.rows });
  } catch (err) {
    console.error("DB ERROR /api/rooms:", err.message);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
});

/* ==================================================
   POST: Update User x/z Position
   FIX: Check rowCount so we return 404 for unknown users.
   FIX: Emit "position-update" socket event so the map
        updates in real time without waiting for a poll.
================================================== */
router.post("/api/update-position", async (req, res) => {
  const { user_id, x_pos, z_pos } = req.body;

  if (!user_id) {
    return res.status(400).json({ success: false, message: "user_id is required" });
  }

  try {
    const result = await pool.query(
      `UPDATE user_locations
       SET x_pos = $1, z_pos = $2, last_seen = NOW()
       WHERE user_id = $3`,
      [x_pos || 0, z_pos || 0, user_id]
    );

    /* No row updated = user_id not in user_locations yet */
    if (result.rowCount === 0) {
      return res.status(404).json({ success: false, message: "User not found — call update-location first" });
    }

    /* Emit real-time position update */
    const io = req.app.get("io");
    if (io) {
      io.emit("position-update", {
        user_id,
        x_pos: x_pos || 0,
        z_pos: z_pos || 0,
        last_seen: new Date().toISOString(),
      });
    }

    return res.json({ success: true });

  } catch (err) {
    console.error("DB ERROR /api/update-position:", err.message);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
});

/* ==================================================
   GET: Room History (last 24h entries for one room)
   Used by the 24h timeline modal.
================================================== */
router.get("/api/room-history/:roomName", async (req, res) => {
  const { roomName } = req.params;
  try {
    const result = await pool.query(
      `SELECT lh.user_id, lh.entered_at
       FROM location_history lh
       JOIN rooms r ON lh.room_id = r.id
       WHERE r.room_name = $1
         AND lh.entered_at >= NOW() - INTERVAL '24 hours'
       ORDER BY lh.entered_at DESC
       LIMIT 200`,
      [roomName]
    );
    return res.json({ success: true, history: result.rows });
  } catch (err) {
    console.error("DB ERROR /api/room-history:", err.message);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
});

/* ==================================================
   GET: All Room Reservations
================================================== */
router.get("/api/room-reservations", async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT room_name, tag, label, set_by, created_at
       FROM room_reservations ORDER BY room_name`
    );
    return res.json({ success: true, reservations: result.rows });
  } catch (err) {
    console.error("DB ERROR /api/room-reservations:", err.message);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
});

/* ==================================================
   POST: Set Room Reservation
================================================== */
router.post("/api/room-reservation", async (req, res) => {
  const { room_name, tag, label, set_by } = req.body;
  if (!room_name || !tag || !label) {
    return res.status(400).json({ success: false, message: "room_name, tag, label required" });
  }
  try {
    await pool.query(
      `INSERT INTO room_reservations (room_name, tag, label, set_by)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (room_name)
       DO UPDATE SET tag=$2, label=$3, set_by=$4, created_at=NOW()`,
      [room_name, tag, label, set_by || null]
    );
    return res.json({ success: true });
  } catch (err) {
    console.error("DB ERROR POST /api/room-reservation:", err.message);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
});

/* ==================================================
   DELETE: Clear Room Reservation
================================================== */
router.delete("/api/room-reservation/:roomName", async (req, res) => {
  const { roomName } = req.params;
  try {
    await pool.query(
      `DELETE FROM room_reservations WHERE room_name = $1`,
      [roomName]
    );
    return res.json({ success: true });
  } catch (err) {
    console.error("DB ERROR DELETE /api/room-reservation:", err.message);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
});

export default router;