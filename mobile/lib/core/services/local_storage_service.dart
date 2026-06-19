import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._(this._preferences);

  final SharedPreferences _preferences;

  static Future<LocalStorageService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorageService._(preferences);
  }

  Future<bool> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  String? getString(String key) {
    return _preferences.getString(key);
  }

  Future<bool> setBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  Future<bool> remove(String key) {
    return _preferences.remove(key);
  }

  Future<bool> clear() {
    return _preferences.clear();
  }
}
