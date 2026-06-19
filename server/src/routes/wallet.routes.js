const express = require("express");
const {
	getUserCoinsController,
	getPaymentHistoryController,
} = require("../controller/wallet.controller");
const auth = require("../middleware/auth");

const router = express.Router();

router.get("/get-coins", auth, getUserCoinsController);
router.get("/payment-history", auth, getPaymentHistoryController);

module.exports = router;
