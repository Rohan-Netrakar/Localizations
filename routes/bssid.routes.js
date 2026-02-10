/**
 * File: bssid.routes.js
 *
 * Responsibility:
 * ----------------------------------------------------
 * This file defines all routes related to:
 * - Mapping Wi-Fi BSSIDs to physical rooms
 * - Registering new room ↔ BSSID associations
 * - Localizing a user/device based on detected BSSID
 *
 * Database:
 * ----------------------------------------------------
 * Uses PostgreSQL with two tables:
 * 1. rooms
 *    - id (PK)
 *    - room_name (unique)
 *
 * 2. room_bssids
 *    - id (PK)
 *    - room_id (FK → rooms.id)
 *    - bssid (MAC address of access point)
 *    - band (2.4GHz / 5GHz / 6GHz)
 *    - ssid_name (Wi-Fi network name)
 *
 * Exposed APIs:
 * ----------------------------------------------------
 * GET  /api
 *      → Renders the BSSID Dashboard UI (Admin / Setup)
 *
 * POST /api/register
 *      → Registers a room and associates a BSSID with it
 *      → Used during initial setup or calibration
 *
 * POST /api/localize
 *      → Accepts a BSSID and returns the mapped room
 *      → Used during real-time localization
 */

import express from "express";
import pool from "../db/index.js";

const router = express.Router();

/* ====================================================
   GET: Render BSSID Dashboard UI
   ====================================================
   Expected Use:
   - Accessed by admin / setup personnel
   - Used to manually register rooms and BSSIDs
   - Renders an EJS dashboard page

   Response:
   - HTML view (bssidDashboard.ejs)
*/
router.get("/api", (req, res) => {
  res.render("bssidDashboard");
});

/* ====================================================
   POST: Register Room + BSSID
   ====================================================
   Purpose:
   - Stores a mapping between a physical room and a Wi-Fi
     access point (BSSID)
   - Ensures room exists before linking BSSID

   Expected Request Body (JSON / form-data):
   {
     room_name: "Lab A",
     bssid: "AA:BB:CC:DD:EE:FF",
     band: "5GHz",
     ssid_name: "Campus_WiFi"
   }

   Behavior:
   1. Validate required fields
   2. Check if room already exists
   3. Create room if not present
   4. Insert BSSID mapping

   Response:
   - success: true/false
   - message: status information
*/
router.post("/api/register", async (req, res) => {
  const { room_name, bssid, band, ssid_name } = req.body;

  // Basic input validation
  if (!room_name || !bssid) {
    return res.status(400).json({
      success: false,
      message: "room_name and bssid are required"
    });
  }

  try {
    /* -----------------------------------------------
       Step 1: Check if the room already exists
    ------------------------------------------------ */
    let roomResult = await pool.query(
      "SELECT id FROM rooms WHERE room_name = $1",
      [room_name]
    );

    let roomId;

    /* -----------------------------------------------
       Step 2: Create room if it does not exist
    ------------------------------------------------ */
    if (roomResult.rows.length === 0) {
      const newRoom = await pool.query(
        "INSERT INTO rooms (room_name) VALUES ($1) RETURNING id",
        [room_name]
      );
      roomId = newRoom.rows[0].id;
    } else {
      roomId = roomResult.rows[0].id;
    }

    /* -----------------------------------------------
       Step 3: Insert BSSID mapping for the room
    ------------------------------------------------ */
    await pool.query(
      `INSERT INTO room_bssids (room_id, bssid, band, ssid_name)
       VALUES ($1, $2, $3, $4)`,
      [roomId, bssid, band, ssid_name]
    );

    res.json({
      success: true,
      message: "Room and BSSID stored successfully"
    });

  } catch (err) {
    console.error("Error registering BSSID:", err);
    res.status(500).json({
      success: false,
      message: "Database error"
    });
  }
});

/* ====================================================
   POST: Localize User / Device
   ====================================================
   Purpose:
   - Determines the physical room based on detected BSSID
   - Used by mobile apps, IoT devices, or web clients

   Expected Request Body:
   {
     bssid: "AA:BB:CC:DD:EE:FF"
   }

   Behavior:
   - Searches for BSSID in room_bssids table
   - Joins with rooms table to get room name

   Response:
   - found: true  → room name returned
   - found: false → unknown location
*/
router.post("/api/localize", async (req, res) => {
  const { bssid } = req.body;

  // Validate input
  if (!bssid) {
    return res.status(400).json({
      success: false,
      message: "bssid is required"
    });
  }

  try {
    const result = await pool.query(
      `SELECT r.room_name
       FROM room_bssids rb
       JOIN rooms r ON rb.room_id = r.id
       WHERE rb.bssid = $1`,
      [bssid]
    );

    // No mapping found → unknown location
    if (result.rows.length === 0) {
      return res.json({
        found: false,
        message: "Unknown location"
      });
    }

    // Location successfully resolved
    res.json({
      found: true,
      room: result.rows[0].room_name
    });

  } catch (err) {
    console.error("Localization error:", err);
    res.status(500).json({
      success: false,
      message: "Database error"
    });
  }
});

export default router;
