const express = require("express");
const path = require("path");

const app = express();

// View engine
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

// Static files
app.use(express.static(path.join(__dirname, "public")));

// Routes

// Load all application routes and mount them at the root URL ("/").
// Any request like "/" or "/localizations" is handled inside ./routes/index.js
const indexRoutes = require("./routes/index");
app.use("/", indexRoutes);


const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
