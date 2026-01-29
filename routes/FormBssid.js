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
    res.render("BssidForm");
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
