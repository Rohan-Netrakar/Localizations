/**
 * File: index.js
 *
 * Purpose:
 * - Handles page navigation routes
 * - Renders public UI pages (landing, localizations)
 *
 * Routes:
 * - GET /               → Landing page
 * - GET /localizations  → Localization overview page
 */
import express from "express";
const router = express.Router();

router.get("/", (req, res) => {
  res.render("landing");
});

router.get("/localizations", (req, res) => {
  res.render("localizations");
});

router.get("/localizations-3d", (req, res) => {
  res.render("localizations_3d");
});

router.get("/localizations-iso", (req, res) => {
  res.render("localizations_iso")
});

  

export default router;
