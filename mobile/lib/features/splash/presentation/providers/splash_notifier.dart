import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/splash_di.dart';
import 'splash_state.dart';

class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() {
    return const SplashState();
  }

  Future<void> checkAuthStatus() async {
    final checkAuthStatusUseCase = ref.read(checkAuthStatusUseCaseProvider);

    state = state.copyWith(isLoading: true);
    final status = await checkAuthStatusUseCase.call();
    state = SplashState(isLoading: false, sessionStatus: status);
  }
}
