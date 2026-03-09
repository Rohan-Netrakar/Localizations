/**
 * File: apk.routes.js
 *
 * Routes responsible for:
 * - Rendering the APK download page
 * - Serving Android APK files
 */

import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const router = express.Router();

/* ==================================================
   ES Module Path Resolution
   ================================================== */

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/* ==================================================
   GET: Display App Page
   ================================================== */

router.get("/display", (req, res) => {
  res.render("app-details");
});

/* ==================================================
   GET: Download APK Version 1
   ================================================== */

router.get("/download-apk-v1", (req, res) => {

  const apkPath = path.join(
    __dirname,
    "../public/apk/IndoorLocalization.apk"
  );

  res.download(apkPath, "IndoorLocalization.apk", (err) => {
    if (err) {
      console.error("APK V1 download error:", err);
      res.status(500).send("Unable to download APK V1");
    }
  });
});

/* ==================================================
   GET: Download APK Version 2
   ================================================== */

router.get("/download-apk-v2", (req, res) => {

  const apkPath = path.join(
    __dirname,
    "../public/apk/localization_2.apk"
  );

  res.download(apkPath, "localization_2.apk", (err) => {
    if (err) {
      console.error("APK V2 download error:", err);
      res.status(500).send("Unable to download APK V2");
    }
  });
});

export default router;