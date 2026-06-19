import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  TokenStorageService(this._storage);

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _themeKey = 'app_theme_mode';

  final FlutterSecureStorage _storage;

  void Function()? _onTokensCleared;

  void setOnTokensCleared(void Function()? callback) {
    _onTokensCleared = callback;
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);

    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    _onTokensCleared?.call();
  }

  // ─── Theme Persistence ────────────────────────────────────────────────────

  Future<void> saveTheme(String themeMode) async {
    await _storage.write(key: _themeKey, value: themeMode);
  }

  Future<String?> getTheme() {
    return _storage.read(key: _themeKey);
  }

  Future<void> clearTheme() async {
    await _storage.delete(key: _themeKey);
  }
}
