const express = require("express");
const {
  createCoinPackages,
  getAllCoinPackages,
} = require("../controller/coin_packages.controller");
const router = express.Router();

router.post("/create", createCoinPackages);
router.get("/all", getAllCoinPackages);

module.exports = router;
