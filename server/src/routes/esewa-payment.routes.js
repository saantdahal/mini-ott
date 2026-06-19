const express = require("express");
const auth = require("../middleware/auth");
const {
  initializeEsewaPaymentController,
  completeEsewaPaymentController,
  confirmEsewaSdkPaymentController,
} = require("../controller/esewa-payment.controller");

const router = express.Router();

router.post("/initialize-payment", auth, initializeEsewaPaymentController);
router.post("/confirm-sdk-payment", auth, confirmEsewaSdkPaymentController);
router.get("/complete-esewa-payment", completeEsewaPaymentController);

module.exports = router;
