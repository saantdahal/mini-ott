import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/di.dart';
import '../../../core/network/api/api_client.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/apple_login_usecase.dart';
import '../domain/usecases/forgot_password_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/google_login_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/register_usecase.dart';
import '../domain/usecases/resend_email_otp_usecase.dart';
import '../domain/usecases/reset_password_usecase.dart';
import '../domain/usecases/verify_email_otp_usecase.dart';
import '../domain/usecases/verify_reset_otp_usecase.dart';

/// Bridges [get_it] singletons to Riverpod where still needed.
final apiClientProvider = Provider<ApiClient>((ref) => getIt<ApiClient>());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => getIt<AuthRepository>(),
);

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => getIt<LoginUseCase>(),
);

final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => getIt<RegisterUseCase>(),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => getIt<LogoutUseCase>(),
);

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>(
  (ref) => getIt<GetCurrentUserUseCase>(),
);

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>(
  (ref) => getIt<ForgotPasswordUseCase>(),
);

final verifyEmailOtpUseCaseProvider = Provider<VerifyEmailOtpUseCase>(
  (ref) => getIt<VerifyEmailOtpUseCase>(),
);

final resendEmailOtpUseCaseProvider = Provider<ResendEmailOtpUseCase>(
  (ref) => getIt<ResendEmailOtpUseCase>(),
);

final verifyResetOtpUseCaseProvider = Provider<VerifyResetOtpUseCase>(
  (ref) => getIt<VerifyResetOtpUseCase>(),
);

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>(
  (ref) => getIt<ResetPasswordUseCase>(),
);

final googleLoginUseCaseProvider = Provider<GoogleLoginUseCase>(
  (ref) => getIt<GoogleLoginUseCase>(),
);

final appleLoginUseCaseProvider = Provider<AppleLoginUseCase>(
  (ref) => getIt<AppleLoginUseCase>(),
);
