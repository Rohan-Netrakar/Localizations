// server.js
// Main entry point of the Indoor Localization application
// Responsible for initializing Express, middleware, routes, and server startup

import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const app = express();

// Fix for __dirname in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/* -------------------------------------------------
   Middleware Configuration
-------------------------------------------------- */

// Parse incoming JSON requests
app.use(express.json());

// Parse URL-encoded form data
app.use(express.urlencoded({ extended: true }));

/* -------------------------------------------------
   View Engine Configuration
-------------------------------------------------- */

app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

/* -------------------------------------------------
   Static Files Configuration
-------------------------------------------------- */

app.use(express.static(path.join(__dirname, "public")));

/* -------------------------------------------------
   Route Imports
-------------------------------------------------- */

import uiRoutes from "./routes/index.js";
import formApiRoutes from "./routes/FormBssid.js";

// Mount routes at root
app.use("/", uiRoutes);
app.use("/", formApiRoutes);

/* -------------------------------------------------
   Server Startup
-------------------------------------------------- */

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`✅ Server running at http://localhost:${PORT}`);
});
