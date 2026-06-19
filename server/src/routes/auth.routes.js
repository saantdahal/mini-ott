const express = require("express");

const {
  register,
  createAdmin,
  login,
  verifyOtp,
  resendOtp,
  forgotPassword,
  verifyResetOtp,
  resetPassword,
  changePassword,
  logout,
  googleMobileLogin,
  appleMobileLogin,
  refresh,
  me,
} = require("../controller/auth.controller");
const auth = require("../middleware/auth");
const uploadMiddleware = require("../middleware/upload");

const router = express.Router();

router.post("/register", uploadMiddleware.single("avatar"), register);
router.post("/create-admin", auth, createAdmin);
router.post("/login", login);
router.post("/verify-otp", verifyOtp);
router.post("/resend-otp", resendOtp);
router.post("/forgot-password", forgotPassword);
router.post("/verify-reset-otp", verifyResetOtp);
router.post("/reset-password", resetPassword);
router.post("/change-password", auth, changePassword);
router.post("/logout", auth, logout);
router.post("/google/mobile-login", googleMobileLogin);
router.post("/apple/mobile-login", appleMobileLogin);
router.post("/refresh", refresh);
router.get("/me", auth, me);

module.exports = router;