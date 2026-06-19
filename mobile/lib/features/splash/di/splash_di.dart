import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/di.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../data/repositories/splash_repository_impl.dart';
import '../domain/repositories/splash_repository.dart';
import '../domain/usecases/check_auth_status_usecase.dart';

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  return SplashRepositoryImpl(getIt<AuthRepository>());
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  return CheckAuthStatusUseCase(ref.watch(splashRepositoryProvider));
});
