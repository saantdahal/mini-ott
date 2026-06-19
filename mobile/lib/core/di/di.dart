import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:miniott/features/auth/domain/usecases/apple_login_usecase.dart';
import 'package:miniott/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:miniott/features/content_catalog/data/repositories/content_catalog_repository_impl.dart';
import 'package:miniott/features/content_catalog/domain/repositories/content_catalog_repository.dart';
import 'package:miniott/features/notification/di/notification_di.dart';
import 'package:miniott/features/payment/esewa/di/payment_esewa_di.dart';
import 'package:miniott/features/payment/khalti/di/payment_khalti_di.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../app/flavor/app_flavor.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/resend_email_otp_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/verify_email_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import '../../features/coins/data/datasources/coin_remote_data_source.dart';
import '../../features/coins/data/datasources/payment_remote_data_source.dart';
import '../../features/livestream/di/livestream_di.dart';
import '../../features/player/di/player_di.dart';
import '../../features/profile/di/profile_di.dart';
import '../../features/search/di/search_di.dart';
import '../network/api/api_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../services/services.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<Dio>()) return;

  final localStorageService = await LocalStorageService.create();

  getIt
    ..registerSingleton<LocalStorageService>(localStorageService)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<TokenStorageService>(
      () => TokenStorageService(getIt<FlutterSecureStorage>()),
    )
    ..registerLazySingleton<SessionService>(
      () => SessionService(getIt<TokenStorageService>()),
    )
    ..registerLazySingleton<NetworkStatusService>(() => NetworkStatusService())
    ..registerLazySingleton<LoggingService>(() => LoggingService());

  final dio = Dio(
    BaseOptions(
      baseUrl: AppFlavorConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(getIt<TokenStorageService>()));
  dio.interceptors.add(
    TokenRefreshInterceptor(getIt<TokenStorageService>(), dio),
  );
  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  getIt
    ..registerSingleton<Dio>(dio)
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()))
    ..registerLazySingleton<ContentCatalogRepository>(
      () => ContentCatalogRepositoryImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(getIt<LocalStorageService>()),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<ApiClient>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        localDataSource: getIt<AuthLocalDataSource>(),
        tokenStorageService: getIt<TokenStorageService>(),
      ),
    )
    ..registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<ForgotPasswordUseCase>(
      () => ForgotPasswordUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<VerifyEmailOtpUseCase>(
      () => VerifyEmailOtpUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<ResendEmailOtpUseCase>(
      () => ResendEmailOtpUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<VerifyResetOtpUseCase>(
      () => VerifyResetOtpUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(getIt<AuthRepository>()),
    );

  getIt
    ..registerLazySingleton<GoogleLoginUseCase>(
      () => GoogleLoginUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<AppleLoginUseCase>(
      () => AppleLoginUseCase(getIt<AuthRepository>()),
    );

  SearchDI.setup();

  ProfileDI.setup();

  LivestreamDI.setup();

  NotificationDI.setup();

  PlayerDI.setup();

  getIt
    ..registerLazySingleton<CoinRemoteDataSource>(
      () =>
          CoinRemoteDataSource(getIt<Dio>(), baseUrl: AppFlavorConfig.baseUrl),
    )
    ..registerLazySingleton<PaymentRemoteDataSource>(
      () => PaymentRemoteDataSourceImpl(
        dio: getIt<Dio>(),
        baseUrl: AppFlavorConfig.baseUrl,
      ),
    );

  registerPaymentEsewa();
  registerPaymentKhalti();
}
