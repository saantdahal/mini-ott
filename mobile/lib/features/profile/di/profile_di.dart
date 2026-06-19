import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/profile_local_data_source.dart';
import 'package:miniott/app/flavor/app_flavor.dart';
import '../../../core/di/di.dart';
import '../data/datasources/profile_remote_data_source.dart';
import '../data/datasources/payment_history_remote_data_source.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/change_password_usecase.dart';
import '../domain/usecases/delete_account_usecase.dart';
import '../domain/usecases/get_user_profile_usecase.dart';
import '../domain/usecases/update_profile_usecase.dart';

// Repository Providers
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: getIt<ProfileRemoteDataSource>(),
    localDataSource: getIt<ProfileLocalDataSource>(),
  );
});

// Use Case Providers
final getUserProfileUseCaseProvider = Provider((ref) {
  return GetUserProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final changePasswordUseCaseProvider = Provider((ref) {
  return ChangePasswordUseCase(ref.watch(profileRepositoryProvider));
});

final deleteAccountUseCaseProvider = Provider((ref) {
  return DeleteAccountUseCase(ref.watch(profileRepositoryProvider));
});

class ProfileDI {
  static void setup() {
    if (getIt.isRegistered<ProfileRemoteDataSource>() &&
        getIt.isRegistered<PaymentHistoryRemoteDataSource>()) {
      return;
    }

    getIt
      ..registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSource(getIt()),
      )
      ..registerLazySingleton<PaymentHistoryRemoteDataSource>(
        () => PaymentHistoryRemoteDataSourceImpl(
          dio: getIt(),
          baseUrl: AppFlavorConfig.baseUrl,
        ),
      )
      ..registerLazySingleton<ProfileLocalDataSource>(
        () => ProfileLocalDataSource(getIt()),
      );
  }
}
