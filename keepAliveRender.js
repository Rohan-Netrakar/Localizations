// keepAliveRender.js
// Keeps Render free-tier service alive by self-pinging

import https from "https";

// 🔁 Your deployed Render URL
const APP_URL = "https://localizations.onrender.com/health";

// ⏱ 14 minutes (safe < 15 min)
const PING_INTERVAL = 14 * 60 * 1000;

function ping() {
  https
    .get(APP_URL, (res) => {
      console.log(
        `🔁 Keep-alive ping | ${new Date().toISOString()} | Status: ${res.statusCode}`
      );
    })
    .on("error", (err) => {
      console.error("❌ Keep-alive error:", err.message);
    });
}

// First ping immediately
ping();

// Repeat ping every 14 minutes
setInterval(ping, PING_INTERVAL);
