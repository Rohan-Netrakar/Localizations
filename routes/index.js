import express from "express";
const router = express.Router();

router.get("/", (req, res) => {
  res.render("landing");
});

router.get("/localizations", (req, res) => {
  res.render("localizations");
});

export default router;
