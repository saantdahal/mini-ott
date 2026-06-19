import '../entities/register_result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});

  /// Server returns 201 with message only for email signup; no session until verified.
  Future<RegisterResult> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? country,
    String? gender,
    String? dateOfBirth,
    String? avatarPath,
  });

  Future<void> logout();

  Future<bool> restoreSessionIfPossible();

  /// Prefers `/api/auth/me` when tokens exist; falls back to cached profile.
  Future<User?> getCurrentUser();

  Future<void> forgotPassword(String email);

  Future<void> verifyEmailOtp({required String email, required String otp});

  Future<void> resendEmailOtp(String email);

  Future<void> verifyResetOtp({required String email, required String otp});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<User> googleLogin({required String idToken});

  Future<User> appleLogin({
    required String identityToken,
    String? email,
    String? fullName,
  });
}
