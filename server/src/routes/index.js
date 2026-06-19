const express = require("express");
const router = express.Router();

/* GET home page. */
router.get("/", function (req, res, next) {
  res.status(200).json({
    success: true,
    title: "Mini OTT Platform Server",
    summary: "Mini OTT backend.",
    runtime: {
      port: process.env.PORT || "3000",
      nodeEnv: process.env.NODE_ENV || "development",
    },
  });
});

module.exports = router;
