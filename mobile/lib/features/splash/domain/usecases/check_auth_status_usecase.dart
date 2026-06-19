import '../entities/session_status.dart';
import '../repositories/splash_repository.dart';

class CheckAuthStatusUseCase {
  CheckAuthStatusUseCase(this._splashRepository);

  final SplashRepository _splashRepository;

  Future<SessionStatus> call() async {
    return _splashRepository.checkSession();
  }
}
