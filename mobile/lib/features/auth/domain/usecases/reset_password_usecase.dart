import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  ResetPasswordUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return _authRepository.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }
}
