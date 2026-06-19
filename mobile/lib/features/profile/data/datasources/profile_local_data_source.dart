import 'dart:convert';

import '../../../../core/services/local_storage_service.dart';
import '../models/user_profile_model.dart';

class ProfileLocalDataSource {
  ProfileLocalDataSource(this._localStorage);

  final LocalStorageService _localStorage;
  static const String _profileKey = 'user_profile';

  Future<void> saveProfile(UserProfileModel profile) async {
    final jsonString = jsonEncode(profile.toJson());
    await _localStorage.setString(_profileKey, jsonString);
  }

  Future<UserProfileModel?> getProfile() async {
    final jsonString = _localStorage.getString(_profileKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserProfileModel.fromJson(data);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearProfile() async {
    await _localStorage.remove(_profileKey);
  }
}
