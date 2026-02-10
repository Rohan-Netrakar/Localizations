/**
 * File: bssid.routes.js
 *
 * Purpose:
 * - Handles User ↔ Wi-Fi BSSID routes for Indoor Localization
 *
 * APIs:
 * - GET  /api            → Render BSSID dashboard UI
 * - POST /update-bssid   → Create / update user BSSID
 * - GET  /users          → Fetch all registered users
 *
 * Note:
 * - Uses in-memory storage (resets on server restart)
 */
import express from "express";

const router = express.Router();

/* ---------------------------
   In-memory user store
   (starts empty)
---------------------------- */
const users = {};

/* ---------------------------
   POST: Create / Update BSSID
---------------------------- */

router.get("/api", (req,res)=>{
    res.render("bssidDashboard");//ejs file
});
router.post("/update-bssid", (req, res) => {
  const { userId, bssid } = req.body;

  // Validation
  if (!userId || !bssid) {
    return res.status(400).json({
      success: false,
      message: "userId and bssid are required"
    });
  }

  // If user does NOT exist → create
  if (!users[userId]) {
    users[userId] = {
      name: userId,     // or "Unknown"
      bssid: ""
    };
  }

  // Update only BSSID
  users[userId].bssid = bssid;

  return res.json({
    success: true,
    message: "BSSID updated successfully",
    data: users[userId]
  });
});

router.get("/users", (req, res) => {
  res.json(users);
});


export default router;
