import 'package:dio/dio.dart';

import '../../../../app/flavor/app_flavor.dart';
import '../../../../core/di/di.dart';
import '../data/esewa_payment_remote_data_source.dart';
import '../data/repositories/esewa_payment_repository_impl.dart';
import '../domain/repositories/esewa_payment_repository.dart';
import '../domain/usecases/initialize_esewa_webview_session_usecase.dart';

void registerPaymentEsewa() {
  if (getIt.isRegistered<EsewaPaymentRemoteDataSource>()) {
    return;
  }
  getIt
    ..registerLazySingleton<EsewaPaymentRemoteDataSource>(
      () => EsewaPaymentRemoteDataSourceImpl(
        dio: getIt<Dio>(),
        baseUrl: AppFlavorConfig.baseUrl,
      ),
    )
    ..registerLazySingleton<EsewaPaymentRepository>(
      () => EsewaPaymentRepositoryImpl(getIt<EsewaPaymentRemoteDataSource>()),
    )
    ..registerLazySingleton<InitializeEsewaWebviewSessionUseCase>(
      () =>
          InitializeEsewaWebviewSessionUseCase(getIt<EsewaPaymentRepository>()),
    );
}
