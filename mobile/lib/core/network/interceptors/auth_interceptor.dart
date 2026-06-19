import 'package:dio/dio.dart';

import '../../services/token_storage_service.dart';
import '../../../shared/models/register_response.dart';

/// Adds `Authorization: Bearer` when an access token exists.
///
/// Set [extra][AuthInterceptor.skipAuthHeaderKey] to `true` to omit the header
/// (e.g. refresh request).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  static const String skipAuthHeaderKey = 'skipAuthHeader';

  final TokenStorageService _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthHeaderKey] == true) {
      return handler.next(options);
    }
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}

/// On 401 with a prior Bearer token, calls `/api/auth/refresh` and retries once.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor(this._tokenStorage, this._dio);

  static const String skipAuthRetryKey = 'skipAuthRetry';

  final TokenStorageService _tokenStorage;
  final Dio _dio;

  Future<String?>? _refreshInFlight;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    if (status != 401) {
      return handler.next(err);
    }

    final req = err.requestOptions;
    if (req.extra[skipAuthRetryKey] == true) {
      return handler.next(err);
    }

    final hadBearer = req.headers['Authorization'] != null;
    if (!hadBearer) {
      return handler.next(err);
    }

    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorage.clearTokens();
      return handler.next(err);
    }

    try {
      final access = await _refreshAccessToken(refreshToken);
      if (access == null || access.isEmpty) {
        await _tokenStorage.clearTokens();
        return handler.next(err);
      }

      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $access';

      final response = await _dio.fetch<dynamic>(opts);
      return handler.resolve(response);
    } catch (_) {
      await _tokenStorage.clearTokens();
      return handler.next(err);
    }
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }
    _refreshInFlight = _doRefresh(refreshToken);
    try {
      return await _refreshInFlight!;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<String?> _doRefresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/refresh',
      data: <String, dynamic>{'refreshToken': refreshToken},
      options: Options(
        extra: <String, dynamic>{
          AuthInterceptor.skipAuthHeaderKey: true,
          skipAuthRetryKey: true,
        },
      ),
    );
    final data = response.data;
    if (data == null) return null;
    final tokens = Tokens.fromJson(data['tokens'] as Map<String, dynamic>);
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens.accessToken;
  }
}
