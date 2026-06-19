import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/email_not_verified_exception.dart';
import '../../../../core/network/api/api_client.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../shared/models/register_response.dart';
import '../models/login_request_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<RegisterResponse> login(LoginRequestModel request) async {
    try {
      final response = await _apiClient.login(request);
      final data = response.data;
      if (data.user != null && data.tokens != null) {
        return data;
      }
      throw const AppException(message: 'Invalid login response');
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          _isEmailNotVerifiedBody(e.response?.data)) {
        final msg = messageFromDio(e);
        throw EmailNotVerifiedException(email: request.email, message: msg);
      }
      throw appExceptionFromDio(e);
    }
  }

  bool _isEmailNotVerifiedBody(Object? data) {
    if (data is! Map<String, dynamic>) return false;
    final code = data['code'];
    if (code is String && code.toUpperCase() == 'EMAIL_NOT_VERIFIED') {
      return true;
    }
    final message = data['message'];
    if (message is String) {
      final lower = message.toLowerCase();
      return lower.contains('verif') &&
          (lower.contains('email') || lower.contains('otp'));
    }
    return false;
  }

  Future<RegisterResponse> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? country,
    String? gender,
    String? dateOfBirth,
    MultipartFile? avatar,
  }) async {
    try {
      final response = await _apiClient.register(
        fullName: fullName,
        email: email,
        password: password,
        authProvider: 'email',
        phone: phone,
        country: country,
        gender: gender,
        dateOfBirth: dateOfBirth,
        avatar: avatar,
      );
      if (response.response.statusCode == 201) {
        return response.data;
      }
      throw AppException(
        message: 'Registration failed',
        statusCode: response.response.statusCode,
      );
    } on DioException catch (e) {
      // Handle email not verified case (400 with "User already registered but not verified" message)
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final message = data['message'];
          if (message is String &&
              message.toLowerCase().contains('not verified')) {
            final msg = messageFromDio(e);
            throw EmailNotVerifiedException(email: email, message: msg);
          }
        }
      }
      throw appExceptionFromDio(e);
    }
  }

  Future<UserData> getMe() async {
    try {
      final response = await _apiClient.me();
      if (response.response.statusCode == 200 && response.data.success) {
        return response.data.user;
      }
      throw const AppException(message: 'Failed to load profile');
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    }
  }

  Future<Tokens> refreshTokens({required String refreshToken}) async {
    try {
      final response = await _apiClient.refresh(<String, dynamic>{
        'refreshToken': refreshToken,
      });
      if (response.response.statusCode == 200 && response.data.success) {
        return response.data.tokens;
      }
      throw const AppException(message: 'Session expired');
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    }
  }

  Future<void> logoutRemote() async {
    try {
      await _apiClient.logout();
    } on DioException {
      return;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiClient.forgotPassword(
        data: <String, dynamic>{'email': email},
      );
      if (response.response.statusCode == 200) {
        return;
      }
      throw AppException(
        message: 'Request failed',
        statusCode: response.response.statusCode,
      );
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    }
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.verifyEmailOtp(
        data: <String, dynamic>{'email': email, 'otp': otp},
      );
      if (response.response.statusCode == 200) {
        return;
      }
      throw AppException(
        message: 'Verification failed',
        statusCode: response.response.statusCode,
      );
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    }
  }

  Future<void> resendEmailOtp(String email) async {
    try {
      final response = await _apiClient.resendEmailOtp(
        data: <String, dynamic>{'email': email},
      );
      if (response.response.statusCode == 200) {
        return;
      }
      throw AppException(
        message: 'Request failed',
        statusCode: response.response.statusCode,
      );
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    }
  }

  Future<void> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.verifyResetOtp(
        data: <String, dynamic>{'email': email, 'otp': otp},
      );
      if (response.response.statusCode == 200) {
        return;
      }
      throw AppException(
        message: 'Verification failed',
        statusCode: response.response.statusCode,
      );
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.resetPassword(
        data: <String, dynamic>{
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        },
      );
      if (response.response.statusCode == 200) {
        return;
      }
      throw AppException(
        message: 'Reset failed',
        statusCode: response.response.statusCode,
      );
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    }
  }

  Future<RegisterResponse> googleLogin({required String idToken}) async {
    try {
      final response = await _apiClient.googleLogin(
        data: <String, dynamic>{'idToken': idToken},
      );
      final data = response.data;
      if (data.user != null && data.tokens != null) {
        return data;
      }
      throw const AppException(message: 'Invalid Google login response');
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    }
  }

  Future<RegisterResponse> appleLogin({
    required String identityToken,
    String? email,
    String? fullName,
  }) async {
    try {
      final response = await _apiClient.appleLogin(
        data: <String, dynamic>{
          'identityToken': identityToken,
          'email': ?email,
          'full_name': ?fullName,
        },
      );
      final data = response.data;
      if (data.user != null && data.tokens != null) {
        return data;
      }
      throw const AppException(message: 'Invalid Apple login response');
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    }
  }
}
