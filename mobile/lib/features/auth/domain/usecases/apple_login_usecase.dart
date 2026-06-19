import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AppleLoginUseCase {
  const AppleLoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<User> call({
    required String identityToken,
    String? email,
    String? fullName,
  }) {
    return _repository.appleLogin(
      identityToken: identityToken,
      email: email,
      fullName: fullName,
    );
  }
}
