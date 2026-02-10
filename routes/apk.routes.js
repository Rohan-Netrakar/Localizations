/**
 * File: apk.routes.js
 *
 * Overview:
 * --------------------------------------------------
 * Defines routes responsible for displaying
 * application details and serving the Android APK
 * file for download.
 *
 * Responsibilities:
 * - Render the application landing/details page
 * - Provide a secure endpoint to download the APK
 *
 * Typical Flow:
 * - User opens app landing page
 * - User clicks "Download APK"
 * - Server sends the APK file to the client
 *
 * Routes:
 * --------------------------------------------------
 * GET  /display
 *      → Renders application details page
 *
 * GET  /download-apk
 *      → Downloads Android APK file
 */

import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const router = express.Router();

/* ==================================================
   ES Module Path Resolution
   ==================================================
   Purpose:
   - __dirname and __filename are not available
     natively in ES Modules.
   - The following logic recreates them safely.
*/
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/* ==================================================
   GET: Render App Details Page
   ==================================================
   Purpose:
   - Serves the application landing/details page
   - Typically contains app description and
     download button for the APK
*/
router.get("/display", (req, res) => {
  res.render("app-details");
});

/* ==================================================
   GET: Download APK File
   ==================================================
   Purpose:
   - Sends the Android APK file to the client
   - Forces browser download using res.download()
   - Handles missing file or server errors
*/
router.get("/download-apk", (req, res) => {

  /* Construct absolute path to APK file */
  const apkPath = path.join(
    __dirname,
    "../public/apk/IndoorLocalization.apk"
  );

  /* Trigger APK download */
  res.download(apkPath, "IndoorLocalization.apk", (err) => {

    /* Handle file access or path errors */
    if (err) {
      console.error("APK download error:", err);
      res.status(500).send("File not found");
    }
  });
});

/* ==================================================
   Export Router
   ==================================================
   Makes routes available to the main application
*/
export default router;
