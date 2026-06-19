import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GoogleLoginUseCase {
  const GoogleLoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<User> call({required String idToken}) {
    return _repository.googleLogin(idToken: idToken);
  }
}
