const express = require("express");
const {
  initializeKhaltiPaymentController,
  completeKhaltiPaymentController,
} = require("../controller/khalti-payment.controller");
const auth = require("../middleware/auth");
const router = express.Router();

router.post("/initialize-payment", auth, initializeKhaltiPaymentController);
router.get("/complete-khalti-payment", completeKhaltiPaymentController);

module.exports = router;
