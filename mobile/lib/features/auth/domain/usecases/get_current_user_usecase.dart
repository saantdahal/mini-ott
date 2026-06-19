import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<User?> call() {
    return _authRepository.getCurrentUser();
  }
}
