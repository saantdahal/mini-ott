import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/session_status.dart';
import '../../domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  SplashRepositoryImpl(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<SessionStatus> checkSession() async {
    final ok = await _authRepository.restoreSessionIfPossible();
    return ok
        ? SessionStatus.authenticated
        : SessionStatus.unauthenticated;
  }
}
