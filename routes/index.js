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

export default router;
