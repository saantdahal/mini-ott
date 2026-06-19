import '../entities/session_status.dart';

abstract class SplashRepository {
  Future<SessionStatus> checkSession();
}
