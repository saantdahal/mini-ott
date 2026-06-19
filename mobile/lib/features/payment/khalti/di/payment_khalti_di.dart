import 'package:dio/dio.dart';

import '../../../../app/flavor/app_flavor.dart';
import '../../../../core/di/di.dart';
import '../data/khalti_payment_remote_data_source.dart';
import '../data/repositories/khalti_payment_repository_impl.dart';
import '../domain/repositories/khalti_payment_repository.dart';
import '../domain/usecases/initialize_khalti_checkout_usecase.dart';

void registerPaymentKhalti() {
  if (getIt.isRegistered<KhaltiPaymentRemoteDataSource>()) {
    return;
  }
  getIt
    ..registerLazySingleton<KhaltiPaymentRemoteDataSource>(
      () => KhaltiPaymentRemoteDataSourceImpl(
        dio: getIt<Dio>(),
        baseUrl: AppFlavorConfig.baseUrl,
      ),
    )
    ..registerLazySingleton<KhaltiPaymentRepository>(
      () => KhaltiPaymentRepositoryImpl(getIt<KhaltiPaymentRemoteDataSource>()),
    )
    ..registerLazySingleton<InitializeKhaltiCheckoutUseCase>(
      () => InitializeKhaltiCheckoutUseCase(getIt<KhaltiPaymentRepository>()),
    );
}
