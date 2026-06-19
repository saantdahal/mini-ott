import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile();

  Future<UserProfile> updateProfile({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? country,
    String? avatarPath,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> deleteAccount({required String password});
}
