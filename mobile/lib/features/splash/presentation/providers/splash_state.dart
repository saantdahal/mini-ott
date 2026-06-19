import '../../domain/entities/session_status.dart';

class SplashState {
  const SplashState({this.isLoading = false, this.sessionStatus});

  final bool isLoading;
  final SessionStatus? sessionStatus;

  SplashState copyWith({bool? isLoading, SessionStatus? sessionStatus}) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      sessionStatus: sessionStatus ?? this.sessionStatus,
    );
  }
}
