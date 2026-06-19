import '../repositories/auth_repository.dart';

class VerifyEmailOtpUseCase {
  VerifyEmailOtpUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call({required String email, required String otp}) {
    return _authRepository.verifyEmailOtp(email: email, otp: otp);
  }
}
