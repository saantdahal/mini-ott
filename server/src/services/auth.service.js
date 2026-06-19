const bcrypt = require("bcryptjs");
const crypto = require("crypto");
const nodemailer = require("nodemailer");
const path = require("path");
const jade = require("jade");
const { admin } = require("../config/firebase");

const Users = require("../model/users.model");
const EmailVerificationOtps = require("../model/email_verification_otps.model");
const DeviceSessions = require("../model/device_sessions.model");
const {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
} = require("../utils/token");
const { uploadImageToCloudinary } = require("../config/cloudinary");

const otpTtlMinutes = parseInt(process.env.OTP_EXPIRES_MINUTES || "10", 10);
const OTP_TTL_MS = otpTtlMinutes * 60 * 1000;

let smtpTransporter;

const getSmtpTransporter = () => {
  if (smtpTransporter) {
    return smtpTransporter;
  }

  const { SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD } = process.env;
  if (!SMTP_HOST || !SMTP_USER || !SMTP_PASSWORD) {
    throw new Error("SMTP_HOST, SMTP_USER or SMTP_PASSWORD is not set.");
  }

  const port = parseInt(SMTP_PORT || "587", 10);
  smtpTransporter = nodemailer.createTransport({
    host: SMTP_HOST,
    port,
    secure: port === 465,
    auth: {
      user: SMTP_USER,
      pass: SMTP_PASSWORD,
    },
  });

  return smtpTransporter;
};

const verifyFirebaseIdToken = async (idToken) => {
  try {
    return await admin.auth().verifyIdToken(idToken);
  } catch (error) {
    throw new Error(`Invalid Firebase token: ${error.message}`);
  }
};

const generateOtp = () => String(Math.floor(100000 + Math.random() * 900000));

const hashToken = (token) =>
  crypto.createHash("sha256").update(token).digest("hex");

const getRequestIpAddress = (req) => {
  const forwardedFor = req?.headers?.["x-forwarded-for"];
  if (typeof forwardedFor === "string" && forwardedFor.trim()) {
    return forwardedFor.split(",")[0].trim();
  }

  return req?.ip || req?.socket?.remoteAddress || null;
};

const getRequestDeviceType = (req) => {
  const userAgent = String(req?.headers?.["user-agent"] || "").toLowerCase();
  if (userAgent.includes("mobile")) {
    return "mobile";
  }

  if (userAgent.includes("tablet")) {
    return "tablet";
  }

  return "web";
};

const getRequestDeviceName = (req) => {
  const userAgent = String(req?.headers?.["user-agent"] || "").trim();
  return userAgent ? userAgent.slice(0, 255) : null;
};

const createDeviceSession = async (user, tokens, req, loginMethod = "email") => {
  await DeviceSessions.create({
    user_id: user.user_id,
    device_type: getRequestDeviceType(req),
    device_name: getRequestDeviceName(req),
    os_name: null,
    browser_name: null,
    ip_address: getRequestIpAddress(req),
    login_method: loginMethod,
    access_token_hash: hashToken(tokens.accessToken),
    refresh_token_hash: hashToken(tokens.refreshToken),
    last_active_at: new Date(),
    expires_at: null,
    is_current: true,
    status: "active",
  });
};

const getActiveSessionByAccessToken = async (userId, token) =>
  DeviceSessions.findOne({
    where: {
      user_id: userId,
      access_token_hash: hashToken(token),
      status: "active",
    },
  });

const getActiveSessionByRefreshToken = async (userId, token) =>
  DeviceSessions.findOne({
    where: {
      user_id: userId,
      refresh_token_hash: hashToken(token),
      status: "active",
    },
  });

const renderEmailTemplate = (templateName, locals = {}) => {
  const templatePath = path.join(
    __dirname,
    "..",
    "views",
    "emails",
    `${templateName}.jade`
  );

  return new Promise((resolve, reject) => {
    jade.renderFile(templatePath, locals, (error, html) => {
      if (error) {
        reject(error);
        return;
      }

      resolve(html);
    });
  });
};

const sendOtpEmail = async (email, fullName, otp) => {
  const transporter = getSmtpTransporter();
  const from = process.env.SMTP_FROM || process.env.SMTP_USER;
  const html = await renderEmailTemplate("verify-otp", {
    fullName: fullName || "User",
    otp,
    expiryMinutes: Math.floor(OTP_TTL_MS / 60000),
  });

  await transporter.sendMail({
    from,
    to: email,
    subject: "Mini OTT - Email Verification OTP",
    html,
  });
};

const sendEmailVerifiedConfirmation = async (email, fullName) => {
  const transporter = getSmtpTransporter();
  const from = process.env.SMTP_FROM || process.env.SMTP_USER;
  const html = await renderEmailTemplate("email-verified", {
    fullName: fullName || "User",
  });

  await transporter.sendMail({
    from,
    to: email,
    subject: "Mini OTT - Email Verified Successfully",
    html,
  });
};

const sendResetPasswordOtpEmail = async (email, fullName, otp) => {
  const transporter = getSmtpTransporter();
  const from = process.env.SMTP_FROM || process.env.SMTP_USER;
  const html = await renderEmailTemplate("reset-password-otp", {
    fullName: fullName || "User",
    otp,
    expiryMinutes: Math.floor(OTP_TTL_MS / 60000),
  });

  await transporter.sendMail({
    from,
    to: email,
    subject: "Mini OTT - Reset Password OTP",
    html,
  });
};

const sendPasswordResetSuccessEmail = async (email, fullName) => {
  const transporter = getSmtpTransporter();
  const from = process.env.SMTP_FROM || process.env.SMTP_USER;
  const html = await renderEmailTemplate("password-reset-success", {
    fullName: fullName || "User",
  });

  await transporter.sendMail({
    from,
    to: email,
    subject: "Mini OTT - Password Changed Successfully",
    html,
  });
};

const issueOtpForUser = async (user) => {
  const otp = generateOtp();

  await EmailVerificationOtps.destroy({
    where: { email: user.email },
  });

  await EmailVerificationOtps.create({
    user_id: user.user_id,
    email: user.email,
    otp_code: otp,
    expires_at: new Date(Date.now() + OTP_TTL_MS),
  });

  await sendOtpEmail(user.email, user.full_name, otp);
};

const tryIssueOtpForUser = async (user) => {
  try {
    await issueOtpForUser(user);
    return true;
  } catch (error) {
    console.error("Failed to send OTP email:", error.message);
    return false;
  }
};

const trySendVerificationSuccessEmail = async (user) => {
  try {
    await sendEmailVerifiedConfirmation(user.email, user.full_name);
  } catch (error) {
    console.error("Failed to send verification success email:", error.message);
  }
};

const getLatestOtpRecord = async (email) =>
  EmailVerificationOtps.findOne({
    where: { email },
    order: [["created_at", "DESC"]],
  });

const issuePasswordResetOtpForUser = async (user) => {
  const otp = generateOtp();

  await EmailVerificationOtps.destroy({
    where: { email: user.email },
  });

  await EmailVerificationOtps.create({
    user_id: user.user_id,
    email: user.email,
    otp_code: otp,
    expires_at: new Date(Date.now() + OTP_TTL_MS),
  });

  await sendResetPasswordOtpEmail(user.email, user.full_name, otp);
};

const trySendPasswordResetSuccessEmail = async (user) => {
  try {
    await sendPasswordResetSuccessEmail(user.email, user.full_name);
  } catch (error) {
    console.error("Failed to send password reset success email:", error.message);
  }
};

const sanitizeUser = (user) => ({
  user_id: user.user_id,
  full_name: user.full_name,
  email: user.email,
  phone: user.phone,
  auth_provider: user.auth_provider,
  avatar_key: user.avatar_key,
  role: user.role,
  gender: user.gender,
  date_of_birth: user.date_of_birth,
  country: user.country,
  is_email_verified: user.is_email_verified,
  status: user.status,
  last_login_at: user.last_login_at,
  created_at: user.created_at,
  updated_at: user.updated_at,
});

const buildAuthResponse = (user) => {
  const userPayload = sanitizeUser(user);
  const accessToken = signAccessToken({
    id: user.user_id,
    role: user.role,
  });
  const refreshToken = signRefreshToken({ id: user.user_id });

  return {
    user: userPayload,
    tokens: {
      accessToken,
      refreshToken,
    },
  };
};

const register = async (payload, imageFile) => {
  const existing = await Users.findOne({ where: { email: payload.email } });
  if (existing) {
    if (!existing.is_email_verified) {
      const otpSent = await tryIssueOtpForUser(existing);
      const error = new Error(
        otpSent
          ? "User already registered but not verified. OTP sent to email."
          : "User already registered but not verified. OTP could not be sent right now."
      );
      error.code = "EMAIL_NOT_VERIFIED";
      throw error;
    }
    throw new Error("User already exists");
  }

  const isEmailAuth = payload.auth_provider === "email";
  const passwordHash = payload.password
    ? await bcrypt.hash(payload.password, 10)
    : null;

  const tempUser = {
    user_id: "temp",
    full_name: payload.full_name,
    email: payload.email,
    phone: payload.phone,
    country: payload.country,
    gender: payload.gender,
    date_of_birth: payload.date_of_birth,
    avatar_key: payload.avatar_key,
    auth_provider: payload.auth_provider,
    role: "user",
    status: "active",
    is_email_verified: !isEmailAuth,
  };

  
  signAccessToken({ id: tempUser.user_id, role: tempUser.role });
  signRefreshToken({ id: tempUser.user_id });

  let avatarKey = payload.avatar_key || null;
  if (imageFile) {
    try {
      const uploadedFile = await uploadImageToCloudinary(
        imageFile.buffer,
        `${Date.now()}-${payload.email}`
      );
      avatarKey = uploadedFile.secure_url;
    } catch (uploadError) {
      throw new Error(`Image upload failed: ${uploadError.message}`);
    }
  }

  const user = await Users.create({
    full_name: payload.full_name,
    email: payload.email,
    phone: payload.phone,
    country: payload.country,
    gender: payload.gender,
    date_of_birth: payload.date_of_birth,
    avatar_key: avatarKey,
    auth_provider: payload.auth_provider,
    password_hash: passwordHash,
    is_email_verified: !isEmailAuth,
  });

  if (isEmailAuth) {
    const otpSent = await tryIssueOtpForUser(user);
    return {
      message: otpSent
        ? "User Registration Success"
        : "User Registration Success, but OTP email could not be sent right now. Please try resend OTP later.",
    };
  }

  return { message: "User Registration Success" };
};

const createAdmin = async (payload) => {
  const existing = await Users.findOne({ where: { email: payload.email } });
  if (existing) {
    throw new Error("User already exists");
  }

  const passwordHash = await bcrypt.hash(payload.password, 10);

  const adminUser = await Users.create({
    full_name: payload.full_name,
    email: payload.email,
    phone: payload.phone,
    country: payload.country,
    gender: payload.gender,
    date_of_birth: payload.date_of_birth,
    avatar_key: payload.avatar_key,
    auth_provider: "email",
    role: "admin",
    password_hash: passwordHash,
    is_email_verified: true,
    status: "active",
  });

  return sanitizeUser(adminUser);
};

const login = async (email, password, req) => {
  const user = await Users.findOne({ where: { email } });
  if (!user) {
    throw new Error("Invalid credentials");
  }

  if (user.auth_provider !== "email") {
    throw new Error(`Use ${user.auth_provider} login for this account`);
  }

  if (!user.password_hash) {
    throw new Error("Password is not set for this account");
  }

  const isValid = await bcrypt.compare(password, user.password_hash);
  if (!isValid) {
    throw new Error("Invalid credentials");
  }

  if (!user.is_email_verified) {
    const otpSent = await tryIssueOtpForUser(user);
    const error = new Error(
      otpSent
        ? "Email is not verified. OTP sent to your email."
        : "Email is not verified. OTP could not be sent right now."
    );
    error.code = "EMAIL_NOT_VERIFIED";
    throw error;
  }

  await user.update({ last_login_at: new Date() });
  const authResponse = buildAuthResponse(user);
  await createDeviceSession(user, authResponse.tokens, req, "email");
  return authResponse;
};

const verifyEmailOtp = async (email, otp) => {
  const user = await Users.findOne({ where: { email } });
  if (!user || user.status !== "active") {
    throw new Error("User not found");
  }

  if (user.is_email_verified) {
    return { message: "Email already verified" };
  }

  const record = await EmailVerificationOtps.findOne({
    where: { email },
    order: [["created_at", "DESC"]],
  });

  if (!record) {
    throw new Error("OTP not found. Please request a new OTP.");
  }

  if (Date.now() > new Date(record.expires_at).getTime()) {
    await EmailVerificationOtps.destroy({ where: { email } });
    throw new Error("OTP expired. Please request a new OTP.");
  }

  if (record.otp_code !== otp) {
    throw new Error("Invalid OTP");
  }

  await user.update({ is_email_verified: true });

  await EmailVerificationOtps.destroy({ where: { email } });

  await trySendVerificationSuccessEmail(user);

  return { message: "Email verified successfully" };
};

const resendEmailOtp = async (email) => {
  const user = await Users.findOne({ where: { email } });
  if (!user || user.status !== "active") {
    throw new Error("User not found");
  }

  if (user.is_email_verified) {
    throw new Error("Email already verified");
  }

  const otpSent = await tryIssueOtpForUser(user);
  if (!otpSent) {
    throw new Error("OTP could not be sent right now. Please try again later.");
  }

  return { message: "OTP sent successfully" };
};

const forgotPassword = async (email) => {
  const user = await Users.findOne({ where: { email } });

  if (!user || user.status !== "active") {
    return {
      message: "If this email is registered, password reset OTP has been sent.",
    };
  }

  if (user.auth_provider !== "email" || !user.password_hash) {
    throw new Error(`Use ${user.auth_provider} login for this account`);
  }

  await issuePasswordResetOtpForUser(user);
  return { message: "Password reset OTP sent to your email" };
};

const verifyPasswordResetOtp = async (email, otp) => {
  const user = await Users.findOne({ where: { email } });
  if (!user || user.status !== "active") {
    throw new Error("User not found");
  }

  if (user.auth_provider !== "email") {
    throw new Error(`Use ${user.auth_provider} login for this account`);
  }

  const record = await getLatestOtpRecord(email);

  if (!record) {
    throw new Error("OTP not found. Please request a new OTP.");
  }

  if (Date.now() > new Date(record.expires_at).getTime()) {
    await EmailVerificationOtps.destroy({ where: { email } });
    throw new Error("OTP expired. Please request a new OTP.");
  }

  if (record.otp_code !== otp) {
    throw new Error("Invalid OTP");
  }

  return { message: "OTP verified successfully" };
};

const resetPasswordWithOtp = async (email, otp, newPassword) => {
  const user = await Users.findOne({ where: { email } });
  if (!user || user.status !== "active") {
    throw new Error("User not found");
  }

  if (user.auth_provider !== "email") {
    throw new Error(`Use ${user.auth_provider} login for this account`);
  }

  const record = await getLatestOtpRecord(email);

  if (!record) {
    throw new Error("OTP not found. Please request a new OTP.");
  }

  if (Date.now() > new Date(record.expires_at).getTime()) {
    await EmailVerificationOtps.destroy({ where: { email } });
    throw new Error("OTP expired. Please request a new OTP.");
  }

  if (record.otp_code !== otp) {
    throw new Error("Invalid OTP");
  }

  const passwordHash = await bcrypt.hash(newPassword, 10);
  await user.update({ password_hash: passwordHash });
  await EmailVerificationOtps.destroy({ where: { email } });

  await trySendPasswordResetSuccessEmail(user);

  return { message: "Password reset successful" };
};

const changePassword = async (userId, currentPassword, newPassword) => {
  const user = await Users.findByPk(userId);

  if (!user || user.status !== "active") {
    throw new Error("User not found");
  }

  if (user.auth_provider !== "email") {
    throw new Error(`Use ${user.auth_provider} login for this account`);
  }

  if (!user.password_hash) {
    throw new Error("Password is not set for this account");
  }

  const isValid = await bcrypt.compare(currentPassword, user.password_hash);
  if (!isValid) {
    throw new Error("Current password is incorrect");
  }

  const passwordHash = await bcrypt.hash(newPassword, 10);
  await user.update({ password_hash: passwordHash });

  await DeviceSessions.destroy({
    where: {
      user_id: userId,
      status: "active",
    },
  });

  return { message: "Password changed successfully" };
};

const logout = async (sessionId, userId) => {
  const session = await DeviceSessions.findOne({
    where: {
      device_session_id: sessionId,
      user_id: userId,
      status: "active",
    },
  });

  if (!session) {
    throw new Error("Session not found");
  }

  await session.destroy();

  return { message: "Logged out successfully" };
};

const refresh = async (refreshToken) => {
  const decoded = verifyRefreshToken(refreshToken);
  const user = await Users.findByPk(decoded.id);

  if (!user || user.status !== "active") {
    throw new Error("User not found");
  }

  const session = await getActiveSessionByRefreshToken(user.user_id, refreshToken);
  if (!session) {
    throw new Error("Session expired. Please login again.");
  }

  const tokens = {
    accessToken: signAccessToken({ id: user.user_id, role: user.role }),
    refreshToken: signRefreshToken({ id: user.user_id }),
  };

  await session.update({
    access_token_hash: hashToken(tokens.accessToken),
    refresh_token_hash: hashToken(tokens.refreshToken),
    last_active_at: new Date(),
    is_current: true,
    status: "active",
  });

  return tokens;
};

const getCurrentUser = async (userId) => {
  const user = await Users.findByPk(userId);
  if (!user || user.status !== "active") {
    throw new Error("User not found");
  }
  return sanitizeUser(user);
};

const googleMobileLogin = async (idToken) => {
  const payload = await verifyFirebaseIdToken(idToken);

  const email = payload?.email ? String(payload.email).toLowerCase().trim() : null;
  if (!email) {
    throw new Error("No email found in Google account");
  }

  if (payload.email_verified === false) {
    throw new Error("Google email is not verified");
  }

  let user = await Users.findOne({ where: { email } });

  if (!user) {
    user = await Users.create({
      full_name: payload.name || email.split("@")[0],
      email,
      auth_provider: "google",
      avatar_key: payload.picture || null,
      is_email_verified: true,
      password_hash: null,
    });
  } else {
    if (!["email", "google"].includes(user.auth_provider)) {
      throw new Error(`Use ${user.auth_provider} login for this account`);
    }

    await user.update({
      is_email_verified: true,
      avatar_key: user.avatar_key || payload.picture || null,
      last_login_at: new Date(),
    });
  }

  const authResponse = buildAuthResponse(user);
  await createDeviceSession(user, authResponse.tokens, null, "google");
  return authResponse;
};

const appleMobileLogin = async ({ identityToken, email, fullName }) => {
  const payload = await verifyFirebaseIdToken(identityToken);

  const tokenEmail = payload?.email ? String(payload.email).toLowerCase().trim() : null;
  const normalizedEmail = email ? String(email).toLowerCase().trim() : tokenEmail;

  if (!normalizedEmail) {
    throw new Error("Apple login requires email on first sign-in. Please provide email from app.");
  }

  if (payload.email_verified === false) {
    throw new Error("Apple email is not verified");
  }

  let user = await Users.findOne({ where: { email: normalizedEmail } });

  if (!user) {
    user = await Users.create({
      full_name: fullName || payload.name || normalizedEmail.split("@")[0],
      email: normalizedEmail,
      auth_provider: "apple",
      is_email_verified: true,
      password_hash: null,
    });
  } else {
    if (!["email", "apple"].includes(user.auth_provider)) {
      throw new Error(`Use ${user.auth_provider} login for this account`);
    }

    await user.update({
      is_email_verified: true,
      last_login_at: new Date(),
    });
  }

  const authResponse = buildAuthResponse(user);
  await createDeviceSession(user, authResponse.tokens, null, "apple");
  return authResponse;
};

module.exports = {
  register,
  createAdmin,
  login,
  refresh,
  getCurrentUser,
  verifyEmailOtp,
  resendEmailOtp,
  forgotPassword,
  verifyPasswordResetOtp,
  resetPasswordWithOtp,
  changePassword,
  logout,
  googleMobileLogin,
  appleMobileLogin,
};