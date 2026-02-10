/**
 * File: bssid.routes.js
 *
 * Overview:
 * --------------------------------------------------
 * Defines API routes for indoor localization using
 * Wi-Fi BSSID (Access Point MAC address).
 *
 * Responsibilities:
 * - Persist room ↔ BSSID mappings in PostgreSQL
 * - Resolve a physical classroom from a detected BSSID
 *
 * Typical Flow:
 * - Admin registers room and its Wi-Fi BSSID(s)
 * - Client/app sends detected BSSID
 * - Backend returns the mapped room name
 *
 * Routes:
 * --------------------------------------------------
 * GET  /api
 *      → Renders admin dashboard for BSSID setup
 *
 * POST /api/register
 *      → Registers a room and associates a BSSID
 *      → Used during initial setup / calibration
 *
 * POST /api/localize
 *      → Resolves room name using detected BSSID
 *      → Used by mobile / IoT / web clients
 */

import express from "express";
import pool from "../db/index.js";

const router = express.Router();

/* ==================================================
   GET: Render BSSID Dashboard
   ==================================================
   Purpose:
   - Serves the admin UI for managing room–BSSID
     mappings.
   - This endpoint only renders the EJS view and
     does not perform any database operations.
*/
router.get("/api", (req, res) => {
  res.render("bssidDashboard"); // EJS admin dashboard
});

/* ==================================================
   POST: Register Room + BSSID
   ==================================================
   Purpose:
   - Creates a new room if it does not exist
   - Associates a Wi-Fi BSSID with that room
   - Prevents duplicate BSSID entries
*/
router.post("/api/register", async (req, res) => {
  const { room_name, bssid, band, ssid_name } = req.body;

  /* Validate mandatory inputs */
  if (!room_name || !bssid) {
    return res.status(400).json({
      success: false,
      message: "room_name and bssid are required"
    });
  }

  try {
    /* ------------------------------------------------
       Step 1: Check whether the room already exists
       ------------------------------------------------ */
    const roomCheck = await pool.query(
      "SELECT id FROM rooms WHERE room_name = $1",
      [room_name]
    );

    let roomId;

    /* ------------------------------------------------
       Step 2: Create room if it does not exist
       ------------------------------------------------ */
    if (roomCheck.rows.length === 0) {
      const roomInsert = await pool.query(
        "INSERT INTO rooms (room_name) VALUES ($1) RETURNING id",
        [room_name]
      );
      roomId = roomInsert.rows[0].id;
    } else {
      roomId = roomCheck.rows[0].id;
    }

    /* ------------------------------------------------
       Step 3: Insert BSSID mapping for the room
       - band and ssid_name are optional metadata
       ------------------------------------------------ */
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
    console.error("DB ERROR:", err.message);

    /* Handle duplicate BSSID (unique constraint) */
    if (err.code === "23505") {
      return res.status(409).json({
        success: false,
        message: "BSSID already exists"
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
   ==================================================
   Purpose:
   - Determines the physical room based on a
     detected Wi-Fi BSSID.
   - Used during real-time indoor localization.
*/
router.post("/api/localize", async (req, res) => {
  const { bssid } = req.body;

  /* Validate input */
  if (!bssid) {
    return res.status(400).json({
      success: false,
      message: "bssid is required"
    });
  }

  try {
    /* Lookup room associated with the given BSSID */
    const result = await pool.query(
      `SELECT r.room_name
       FROM room_bssids rb
       JOIN rooms r ON rb.room_id = r.id
       WHERE rb.bssid = $1`,
      [bssid]
    );

    /* No mapping found */
    if (result.rows.length === 0) {
      return res.json({
        found: false,
        message: "Room not found"
      });
    }

    /* Successful localization */
    return res.json({
      found: true,
      room: result.rows[0].room_name
    });

  } catch (err) {
    console.error("DB ERROR:", err.message);

    return res.status(500).json({
      success: false,
      message: "Internal server error"
    });
  }
});

export default router;
