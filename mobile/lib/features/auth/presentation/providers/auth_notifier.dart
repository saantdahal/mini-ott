import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/email_not_verified_exception.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../di/auth_di.dart';
import '../../domain/entities/register_result.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> login({required String email, required String password}) async {
    final loginUseCase = ref.read(loginUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      clearVerificationHints: true,
      actionType: AuthActionType.login,
    );

    try {
      final user = await loginUseCase.call(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        user: user,
        clearError: true,
        actionType: AuthActionType.login,
        successMessage: 'Login successful',
      );
    } on EmailNotVerifiedException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        loginEmailForVerification: e.email,
        actionType: AuthActionType.login,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: AuthActionType.login,
      );
    }
  }

  Future<void> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? country,
    String? gender,
    String? dateOfBirth,
    String? avatarPath,
  }) async {
    final registerUseCase = ref.read(registerUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      clearVerificationHints: true,
      actionType: AuthActionType.signup,
    );

    try {
      final result = await registerUseCase.call(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        country: country,
        gender: gender,
        dateOfBirth: dateOfBirth,
        avatarPath: avatarPath,
      );
      if (result is RegisterNeedsEmailVerification) {
        state = state.copyWith(
          isLoading: false,
          clearError: true,
          actionType: AuthActionType.signup,
          successMessage: result.message,
          signupEmailForVerification: result.email,
        );
      }
    } on EmailNotVerifiedException catch (e) {
      // User already registered but email not verified - show OTP screen
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        actionType: AuthActionType.signup,
        successMessage: e.message,
        signupEmailForVerification: e.email,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: AuthActionType.signup,
      );
    }
  }

  Future<void> logout() async {
    final logoutUseCase = ref.read(logoutUseCaseProvider);
    await logoutUseCase.call();
    state = const AuthState();
  }

  void clearSession() {
    state = const AuthState();
  }

  Future<void> loadCurrentUser() async {
    final getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);

    try {
      final user = await getCurrentUserUseCase.call();
      state = state.copyWith(
        user: user,
        clearError: true,
        clearSuccess: true,
        actionType: AuthActionType.loadUser,
      );
    } catch (_) {
      state = const AuthState();
    }
  }

  Future<void> forgotPassword(String email) async {
    final forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      actionType: AuthActionType.forgotPassword,
    );

    try {
      await forgotPasswordUseCase.call(email);
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        actionType: AuthActionType.forgotPassword,
        successMessage: 'Verification code sent to your email',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: AuthActionType.forgotPassword,
      );
    }
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final verifyEmailOtpUseCase = ref.read(verifyEmailOtpUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      actionType: AuthActionType.verifyEmailOtp,
    );

    try {
      await verifyEmailOtpUseCase.call(email: email, otp: otp);
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        actionType: AuthActionType.verifyEmailOtp,
        successMessage: 'Email verified. You can sign in now.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: AuthActionType.verifyEmailOtp,
      );
    }
  }

  Future<void> resendEmailOtp(String email) async {
    final resendEmailOtpUseCase = ref.read(resendEmailOtpUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      actionType: AuthActionType.verifyEmailOtp,
    );

    try {
      await resendEmailOtpUseCase.call(email);
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        actionType: AuthActionType.verifyEmailOtp,
        successMessage: 'Verification code sent to your email',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: AuthActionType.verifyEmailOtp,
      );
    }
  }

  Future<void> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final verifyResetOtpUseCase = ref.read(verifyResetOtpUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      actionType: AuthActionType.verifyOtp,
    );

    try {
      await verifyResetOtpUseCase.call(email: email, otp: otp);
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        actionType: AuthActionType.verifyOtp,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: AuthActionType.verifyOtp,
      );
    }
  }

  Future<void> resendPasswordResetOtp(String email) async {
    final forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      actionType: AuthActionType.verifyOtp,
    );

    try {
      await forgotPasswordUseCase.call(email);
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        actionType: AuthActionType.verifyOtp,
        successMessage: 'Verification code sent to your email',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: AuthActionType.verifyOtp,
      );
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final resetPasswordUseCase = ref.read(resetPasswordUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      actionType: AuthActionType.resetPassword,
    );

    try {
      await resetPasswordUseCase.call(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        actionType: AuthActionType.resetPassword,
        successMessage: 'Password reset successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: AuthActionType.resetPassword,
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  void clearVerificationHints() {
    state = state.copyWith(clearVerificationHints: true);
  }

  Future<void> googleLogin({required String idToken}) async {
    final googleLoginUseCase = ref.read(googleLoginUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      clearVerificationHints: true,
      actionType: AuthActionType.login,
    );

    try {
      final user = await googleLoginUseCase.call(idToken: idToken);
      state = state.copyWith(
        isLoading: false,
        user: user,
        clearError: true,
        actionType: AuthActionType.login,
        successMessage: 'Google login successful',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: AuthActionType.login,
      );
    }
  }

  Future<void> appleLogin({
    required String identityToken,
    String? email,
    String? fullName,
  }) async {
    final appleLoginUseCase = ref.read(appleLoginUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      clearVerificationHints: true,
      actionType: AuthActionType.login,
    );

    try {
      final user = await appleLoginUseCase.call(
        identityToken: identityToken,
        email: email,
        fullName: fullName,
      );
      state = state.copyWith(
        isLoading: false,
        user: user,
        clearError: true,
        actionType: AuthActionType.login,
        successMessage: 'Apple login successful',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: AuthActionType.login,
      );
    }
  }
}
