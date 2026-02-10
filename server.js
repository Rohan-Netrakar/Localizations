// server.js
// Main entry point of the Indoor Localization application

import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import dotenv from "dotenv";

dotenv.config();
const app = express();

/* -------------------------------------------------
   Fix for __dirname in ES modules
-------------------------------------------------- */

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/* -------------------------------------------------
   Middleware
-------------------------------------------------- */

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

/* -------------------------------------------------
   View Engine
-------------------------------------------------- */

app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

/* -------------------------------------------------
   Static Files
-------------------------------------------------- */

app.use(express.static(path.join(__dirname, "public")));

/* -------------------------------------------------
   Health Check (Render requirement)
-------------------------------------------------- */

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

/* -------------------------------------------------
   Routes
-------------------------------------------------- */

import uiRoutes from "./routes/index.js"; //landing and localizarions
import formApiRoutes from "./routes/bssid.routes.js"; // bssidDashboard

app.use("/", uiRoutes);
app.use("/", formApiRoutes);

/* -------------------------------------------------
   Server Start
-------------------------------------------------- */
console.log("DB:", process.env.DB_NAME);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);

  // Load keep-alive ONLY in production (Render)
  if (process.env.NODE_ENV === "production") {
    import("./keepAliveRender.js");
  }
});
