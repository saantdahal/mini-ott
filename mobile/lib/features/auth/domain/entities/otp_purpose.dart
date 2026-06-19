/// Which OTP flow the verify screen is serving.
enum OtpPurpose {
  /// `/api/auth/verify-otp` + `/api/auth/resend-otp` (signup / login 403).
  emailVerification,

  /// `/api/auth/verify-reset-otp` + `/api/auth/forgot-password` resend.
  passwordReset,
}
