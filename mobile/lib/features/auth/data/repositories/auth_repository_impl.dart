import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../../core/services/token_storage_service.dart';
import '../../domain/entities/register_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../mappers/auth_mapper.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required TokenStorageService tokenStorageService,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _tokenStorageService = tokenStorageService;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final TokenStorageService _tokenStorageService;

  @override
  Future<User> login({required String email, required String password}) async {
    final response = await _remoteDataSource.login(
      LoginRequestModel(email: email, password: password),
    );
    final user = response.user;
    final tokens = response.tokens;
    if (user == null || tokens == null) {
      throw StateError('Login response missing user or tokens');
    }

    await _tokenStorageService.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    await _localDataSource.saveUser(
      id: user.userId,
      email: user.email,
      name: user.fullName,
    );

    return User(id: user.userId, email: user.email, name: user.fullName);
  }

  @override
  Future<RegisterResult> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? country,
    String? gender,
    String? dateOfBirth,
    String? avatarPath,
  }) async {
    MultipartFile? avatar;
    if (avatarPath != null) {
      avatar = await MultipartFile.fromFile(avatarPath);
    }

    final response = await _remoteDataSource.register(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      country: country,
      gender: gender,
      dateOfBirth: dateOfBirth,
      avatar: avatar,
    );

    return RegisterNeedsEmailVerification(
      email: email,
      message: response.message,
    );
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logoutRemote();
    await _tokenStorageService.clearTokens();
    await _localDataSource.clearUser();
  }

  @override
  Future<bool> restoreSessionIfPossible() async {
    final access = await _tokenStorageService.getAccessToken();
    if (access != null && access.isNotEmpty) {
      try {
        if (!JwtDecoder.isExpired(access)) {
          return true;
        }
      } on Object {
        await _tokenStorageService.clearTokens();
        await _localDataSource.clearUser();
        return false;
      }
    }

    final refresh = await _tokenStorageService.getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      await _tokenStorageService.clearTokens();
      await _localDataSource.clearUser();
      return false;
    }

    try {
      final tokens = await _remoteDataSource.refreshTokens(
        refreshToken: refresh,
      );
      await _tokenStorageService.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return true;
    } on Object {
      await _tokenStorageService.clearTokens();
      await _localDataSource.clearUser();
      return false;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await _tokenStorageService.getAccessToken();
    if (token == null || token.isEmpty) {
      await _localDataSource.clearUser();
      return null;
    }

    try {
      final user = await _remoteDataSource.getMe();
      await _localDataSource.saveUser(
        id: user.userId,
        email: user.email,
        name: user.fullName,
      );
      return User(id: user.userId, email: user.email, name: user.fullName);
    } on Object {
      final tokenAfter = await _tokenStorageService.getAccessToken();
      if (tokenAfter == null || tokenAfter.isEmpty) {
        await _localDataSource.clearUser();
        return null;
      }

      final rawUser = await _localDataSource.getUser();
      if (rawUser == null) {
        return null;
      }

      final model = UserModel.fromJson(rawUser);
      return model.toEntity();
    }
  }

  @override
  Future<void> forgotPassword(String email) {
    return _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> verifyEmailOtp({required String email, required String otp}) {
    return _remoteDataSource.verifyEmailOtp(email: email, otp: otp);
  }

  @override
  Future<void> resendEmailOtp(String email) {
    return _remoteDataSource.resendEmailOtp(email);
  }

  @override
  Future<void> verifyResetOtp({required String email, required String otp}) {
    return _remoteDataSource.verifyResetOtp(email: email, otp: otp);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return _remoteDataSource.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }

  @override
  Future<User> googleLogin({required String idToken}) async {
    final response = await _remoteDataSource.googleLogin(idToken: idToken);
    final user = response.user;
    final tokens = response.tokens;
    if (user == null || tokens == null) {
      throw StateError('Google login response missing user or tokens');
    }

    await _tokenStorageService.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    await _localDataSource.saveUser(
      id: user.userId,
      email: user.email,
      name: user.fullName,
    );

    return User(id: user.userId, email: user.email, name: user.fullName);
  }

  @override
  Future<User> appleLogin({
    required String identityToken,
    String? email,
    String? fullName,
  }) async {
    final response = await _remoteDataSource.appleLogin(
      identityToken: identityToken,
      email: email,
      fullName: fullName,
    );
    final user = response.user;
    final tokens = response.tokens;
    if (user == null || tokens == null) {
      throw StateError('Apple login response missing user or tokens');
    }

    await _tokenStorageService.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    await _localDataSource.saveUser(
      id: user.userId,
      email: user.email,
      name: user.fullName,
    );

    return User(id: user.userId, email: user.email, name: user.fullName);
  }
}
