const authService = require("../services/auth.service");
const {
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
} = require("../validator/auth.validator");

const register = async (req, res) => {
	try {
		const payload = validateRegisterPayload(req.body);
		const imageFile = req.file;

		const result = await authService.register(payload, imageFile);

		return res.status(201).json({
			success: true,
			message: result.message || "User Registration Success",
		});
	} catch (error) {
		const statusCode = error.message.includes("already exists") ? 409 : 400;
		return res.status(statusCode).json({
			success: false,
			message: error.message,
		});
	}
};

const createAdmin = async (req, res) => {
	try {
		if (req.user.role !== "admin") {
			return res.status(403).json({
				success: false,
				message: "Only admin can create another admin",
			});
		}

		const payload = validateCreateAdminPayload(req.body);
		const result = await authService.createAdmin(payload);

		return res.status(201).json({
			success: true,
			message: "Admin created successfully",
			admin: result,
		});
	} catch (error) {
		const statusCode = error.message.includes("already exists") ? 409 : 400;
		return res.status(statusCode).json({
			success: false,
			message: error.message,
		});
	}
};

const login = async (req, res) => {
	try {
		const { email, password } = validateLoginPayload(req.body);
		const result = await authService.login(email, password, req);

		return res.status(200).json({
			success: true,
			message: "Login successful",
			...result,
		});
	} catch (error) {
		if (error.code === "EMAIL_NOT_VERIFIED") {
			return res.status(403).json({
				success: false,
				message: error.message,
			});
		}

		return res.status(400).json({
			success: false,
			message: error.message,
		});
	}
};

const verifyOtp = async (req, res) => {
	try {
		const { email, otp } = validateVerifyOtpPayload(req.body);
		const result = await authService.verifyEmailOtp(email, otp);

		return res.status(200).json({
			success: true,
			message: result.message,
		});
	} catch (error) {
		return res.status(400).json({
			success: false,
			message: error.message,
		});
	}
};

const resendOtp = async (req, res) => {
	try {
		const { email } = validateResendOtpPayload(req.body);
		const result = await authService.resendEmailOtp(email);

		return res.status(200).json({
			success: true,
			message: result.message,
		});
	} catch (error) {
		return res.status(400).json({
			success: false,
			message: error.message,
		});
	}
};

const forgotPassword = async (req, res) => {
	try {
		const { email } = validateForgotPasswordPayload(req.body);
		const result = await authService.forgotPassword(email);

		return res.status(200).json({
			success: true,
			message: result.message,
		});
	} catch (error) {
		return res.status(400).json({
			success: false,
			message: error.message,
		});
	}
};

const verifyResetOtp = async (req, res) => {
	try {
		const { email, otp } = validateVerifyResetOtpPayload(req.body);
		const result = await authService.verifyPasswordResetOtp(email, otp);

		return res.status(200).json({
			success: true,
			message: result.message,
		});
	} catch (error) {
		return res.status(400).json({
			success: false,
			message: error.message,
		});
	}
};

const resetPassword = async (req, res) => {
	try {
		const { email, otp, new_password } = validateResetPasswordPayload(req.body);
		const result = await authService.resetPasswordWithOtp(email, otp, new_password);

		return res.status(200).json({
			success: true,
			message: result.message,
		});
	} catch (error) {
		return res.status(400).json({
			success: false,
			message: error.message,
		});
	}
};

const changePassword = async (req, res) => {
	try {
		const { current_password, new_password } = validateChangePasswordPayload(req.body);
		const result = await authService.changePassword(
			req.user.id,
			current_password,
			new_password,
		);

		return res.status(200).json({
			success: true,
			message: result.message,
		});
	} catch (error) {
		return res.status(400).json({
			success: false,
			message: error.message,
		});
	}
};

const logout = async (req, res) => {
	try {
		const result = await authService.logout(req.deviceSession.device_session_id, req.user.id);

		return res.status(200).json({
			success: true,
			message: result.message,
		});
	} catch (error) {
		return res.status(400).json({
			success: false,
			message: error.message,
		});
	}
};

const googleMobileLogin = async (req, res) => {
	try {
		const { idToken } = validateGoogleLoginPayload(req.body);
		const result = await authService.googleMobileLogin(idToken);

		return res.status(200).json({
			success: true,
			message: "Google login successful",
			...result,
		});
	} catch (error) {
		const statusCode =
			error.message.includes("Invalid Google token") ||
			error.message.includes("expired") ||
			error.message.includes("audience")
				? 401
				: 400;

		return res.status(statusCode).json({
			success: false,
			message: error.message,
		});
	}
};

const appleMobileLogin = async (req, res) => {
	try {
		const { identityToken, email, full_name } = validateAppleLoginPayload(req.body);
		const result = await authService.appleMobileLogin({
			identityToken,
			email,
			fullName: full_name,
		});

		return res.status(200).json({
			success: true,
			message: "Apple login successful",
			...result,
		});
	} catch (error) {
		const statusCode =
			error.message.includes("Invalid Apple token") ||
			error.message.includes("expired") ||
			error.message.includes("audience")
				? 401
				: 400;

		return res.status(statusCode).json({
			success: false,
			message: error.message,
		});
	}
};

const refresh = async (req, res) => {
	try {
		const { refreshToken } = validateRefreshPayload(req.body);
		const tokens = await authService.refresh(refreshToken);

		return res.status(200).json({
			success: true,
			tokens,
		});
	} catch (error) {
		return res.status(401).json({
			success: false,
			message: "Invalid refresh token",
		});
	}
};

const me = async (req, res) => {
	try {
		const user = await authService.getCurrentUser(req.user.id);
		return res.status(200).json({
			success: true,
			user,
		});
	} catch (error) {
		return res.status(404).json({
			success: false,
			message: error.message,
		});
	}
};

module.exports = {
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
};
