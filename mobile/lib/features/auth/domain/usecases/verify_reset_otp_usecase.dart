import '../repositories/auth_repository.dart';

class VerifyResetOtpUseCase {
  VerifyResetOtpUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call({required String email, required String otp}) {
    return _authRepository.verifyResetOtp(email: email, otp: otp);
  }
}
