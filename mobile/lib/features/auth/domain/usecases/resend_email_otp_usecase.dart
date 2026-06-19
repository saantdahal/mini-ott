import '../repositories/auth_repository.dart';

class ResendEmailOtpUseCase {
  ResendEmailOtpUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call(String email) {
    return _authRepository.resendEmailOtp(email);
  }
}
