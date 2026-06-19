import '../../domain/entities/user.dart';

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.actionType = AuthActionType.none,
    this.successMessage,
    this.signupEmailForVerification,
    this.loginEmailForVerification,
  });

  final bool isLoading;
  final User? user;
  final String? errorMessage;
  final String? successMessage;
  final AuthActionType actionType;

  /// After successful signup, navigate to email OTP with this address.
  final String? signupEmailForVerification;

  /// When login returns unverified email (403), navigate to email OTP with this address.
  final String? loginEmailForVerification;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
    String? successMessage,
    AuthActionType? actionType,
    String? signupEmailForVerification,
    String? loginEmailForVerification,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearVerificationHints = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      actionType: actionType ?? this.actionType,
      signupEmailForVerification: clearVerificationHints
          ? null
          : (signupEmailForVerification ?? this.signupEmailForVerification),
      loginEmailForVerification: clearVerificationHints
          ? null
          : (loginEmailForVerification ?? this.loginEmailForVerification),
    );
  }
}

enum AuthActionType {
  none,
  login,
  signup,
  logout,
  forgotPassword,
  verifyOtp,
  verifyEmailOtp,
  changePassword,
  resetPassword,
  loadUser,
}

/// Granular flags for [NotifierProvider.select] to limit rebuilds.
extension AuthStateUi on AuthState {
  bool get loginLoading =>
      actionType == AuthActionType.login && isLoading;

  String? get loginError =>
      actionType == AuthActionType.login ? errorMessage : null;

  bool get signupLoading =>
      actionType == AuthActionType.signup && isLoading;

  String? get signupError =>
      actionType == AuthActionType.signup ? errorMessage : null;

  bool get forgotPasswordLoading =>
      actionType == AuthActionType.forgotPassword && isLoading;

  String? get forgotPasswordError =>
      actionType == AuthActionType.forgotPassword ? errorMessage : null;

  bool get verifyEmailOtpLoading =>
      actionType == AuthActionType.verifyEmailOtp && isLoading;

  String? get verifyEmailOtpError =>
      actionType == AuthActionType.verifyEmailOtp ? errorMessage : null;

  bool get verifyResetOtpLoading =>
      actionType == AuthActionType.verifyOtp && isLoading;

  String? get verifyResetOtpError =>
      actionType == AuthActionType.verifyOtp ? errorMessage : null;

  bool get resetPasswordLoading =>
      actionType == AuthActionType.resetPassword && isLoading;

  String? get resetPasswordError =>
      actionType == AuthActionType.resetPassword ? errorMessage : null;
}
