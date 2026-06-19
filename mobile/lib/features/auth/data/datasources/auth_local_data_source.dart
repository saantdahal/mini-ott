import '../../../../core/services/local_storage_service.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._localStorageService);

  final LocalStorageService _localStorageService;

  static const String _userIdKey = 'auth_user_id';
  static const String _userEmailKey = 'auth_user_email';
  static const String _userNameKey = 'auth_user_name';

  Future<void> saveUser({
    required String id,
    required String email,
    required String name,
  }) async {
    await _localStorageService.setString(_userIdKey, id);
    await _localStorageService.setString(_userEmailKey, email);
    await _localStorageService.setString(_userNameKey, name);
  }

  Future<Map<String, String>?> getUser() async {
    final id = _localStorageService.getString(_userIdKey);
    final email = _localStorageService.getString(_userEmailKey);
    final name = _localStorageService.getString(_userNameKey);

    if (id == null || email == null || name == null) {
      return null;
    }

    return <String, String>{'id': id, 'email': email, 'name': name};
  }

  Future<void> clearUser() async {
    await _localStorageService.remove(_userIdKey);
    await _localStorageService.remove(_userEmailKey);
    await _localStorageService.remove(_userNameKey);
  }
}
