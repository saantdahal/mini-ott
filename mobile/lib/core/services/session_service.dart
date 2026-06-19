import 'package:jwt_decoder/jwt_decoder.dart';

import 'token_storage_service.dart';

class SessionService {
  SessionService(this._tokenStorageService);

  final TokenStorageService _tokenStorageService;

  Future<bool> isLoggedIn() async {
    try {
      final token = await _tokenStorageService.getAccessToken();

      if (token == null || token.isEmpty) {
        return false;
      }

      return !JwtDecoder.isExpired(token);
    } catch (e) {
      // If JWT decoding fails, clear the invalid token and return false
      await clearSession();
      return false;
    }
  }

  Future<void> clearSession() {
    return _tokenStorageService.clearTokens();
  }
}
