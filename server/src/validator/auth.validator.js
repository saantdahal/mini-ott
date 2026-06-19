const Joi = require("joi");

const optionalStringOrNull = (max) =>
  Joi.string().trim().max(max).empty("").default(null).allow(null);

const registerSchema = Joi.object({
  full_name: Joi.string().trim().min(2).max(150).required(),
  email: Joi.string().trim().lowercase().max(255).email().required(),
  password: Joi.when("auth_provider", {
    is: "email",
    then: Joi.string().min(8).max(72).required(),
    otherwise: Joi.string().min(8).max(72).optional(),
  }),
  auth_provider: Joi.string()
    .trim()
    .lowercase()
    .valid("email", "google", "apple")
    .default("email"),
  phone: optionalStringOrNull(30),
  country: optionalStringOrNull(100),
  gender: Joi.string()
    .trim()
    .lowercase()
    .valid("male", "female", "other")
    .empty("")
    .default(null)
    .allow(null),
  date_of_birth: Joi.date().iso().max("now").empty("").default(null).allow(null),
  avatar_key: optionalStringOrNull(500),
});

const createAdminSchema = Joi.object({
  full_name: Joi.string().trim().min(2).max(150).required(),
  email: Joi.string().trim().lowercase().max(255).email().required(),
  password: Joi.string().min(8).max(72).required(),
  phone: optionalStringOrNull(30),
  country: optionalStringOrNull(100),
  gender: Joi.string()
    .trim()
    .lowercase()
    .valid("male", "female", "other")
    .empty("")
    .default(null)
    .allow(null),
  date_of_birth: Joi.date().iso().max("now").empty("").default(null).allow(null),
  avatar_key: optionalStringOrNull(500),
});

const loginSchema = Joi.object({
  email: Joi.string().trim().lowercase().email().required(),
  password: Joi.string().min(8).max(72).required(),
});

const refreshSchema = Joi.object({
  refreshToken: Joi.string().trim().required(),
});

const verifyOtpSchema = Joi.object({
  email: Joi.string().trim().lowercase().email().required(),
  otp: Joi.string().trim().pattern(/^\d{6}$/).required(),
});

const resendOtpSchema = Joi.object({
  email: Joi.string().trim().lowercase().email().required(),
});

const forgotPasswordSchema = Joi.object({
  email: Joi.string().trim().lowercase().email().required(),
});

const verifyResetOtpSchema = Joi.object({
  email: Joi.string().trim().lowercase().email().required(),
  otp: Joi.string().trim().pattern(/^\d{6}$/).required(),
});

const resetPasswordSchema = Joi.object({
  email: Joi.string().trim().lowercase().email().required(),
  otp: Joi.string().trim().pattern(/^\d{6}$/).required(),
  new_password: Joi.string().min(8).max(72).required(),
});

const changePasswordSchema = Joi.object({
  current_password: Joi.string().min(8).max(72).required(),
  new_password: Joi.string().min(8).max(72).required(),
});

const googleLoginSchema = Joi.object({
  idToken: Joi.string().trim().required(),
});

const appleLoginSchema = Joi.object({
  identityToken: Joi.string().trim().required(),
  email: Joi.string().trim().lowercase().email().optional(),
  full_name: Joi.string().trim().min(2).max(150).optional(),
});

const validateWithSchema = (schema, body) => {
  const { error, value } = schema.validate(body, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    throw new Error(error.details.map((item) => item.message).join(", "));
  }

  return value;
};

const validateRegisterPayload = (body) => validateWithSchema(registerSchema, body);

const validateCreateAdminPayload = (body) =>
  validateWithSchema(createAdminSchema, body);

const validateLoginPayload = (body) => validateWithSchema(loginSchema, body);

const validateRefreshPayload = (body) => validateWithSchema(refreshSchema, body);

const validateVerifyOtpPayload = (body) =>
  validateWithSchema(verifyOtpSchema, body);

const validateResendOtpPayload = (body) =>
  validateWithSchema(resendOtpSchema, body);

const validateForgotPasswordPayload = (body) =>
  validateWithSchema(forgotPasswordSchema, body);

const validateVerifyResetOtpPayload = (body) =>
  validateWithSchema(verifyResetOtpSchema, body);

const validateResetPasswordPayload = (body) =>
  validateWithSchema(resetPasswordSchema, body);

const validateChangePasswordPayload = (body) =>
  validateWithSchema(changePasswordSchema, body);

const validateGoogleLoginPayload = (body) =>
  validateWithSchema(googleLoginSchema, body);

const validateAppleLoginPayload = (body) =>
  validateWithSchema(appleLoginSchema, body);

module.exports = {
  validateRegisterPayload,
  validateCreateAdminPayload,
  validateLoginPayload,
  validateRefreshPayload,
  validateVerifyOtpPayload,
  validateResendOtpPayload,
  validateForgotPasswordPayload,
  validateVerifyResetOtpPayload,
  validateResetPasswordPayload,
  validateChangePasswordPayload,
  validateGoogleLoginPayload,
  validateAppleLoginPayload,
};
