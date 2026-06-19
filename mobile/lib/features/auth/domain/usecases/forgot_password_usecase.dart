import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  ForgotPasswordUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call(String email) {
    return _authRepository.forgotPassword(email);
  }
}
