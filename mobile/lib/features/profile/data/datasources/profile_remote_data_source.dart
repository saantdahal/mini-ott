import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api/api_client.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/user_profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfileModel> getUserProfile() async {
    final response = await _apiClient.me();
    if (response.response.statusCode == 200 && response.data.success) {
      return UserProfileModel.fromJson({
        'id': response.data.user.userId,
        'email': response.data.user.email,
        'full_name': response.data.user.fullName,
        'phone': response.data.user.phone,
        'avatar_url': response.data.user.avatarKey,
        'gender': response.data.user.gender,
        'date_of_birth': response.data.user.dateOfBirth,
        'country': response.data.user.country,
        'created_at': response.data.user.createdAt,
        'email_verified': response.data.user.isEmailVerified ?? false,
        'status': response.data.user.status ?? 'active',
      });
    }
    throw Exception('Failed to load profile');
  }

  Future<UserProfileModel> updateProfile({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? country,
    MultipartFile? avatar,
  }) async {
    final response = await _apiClient.updateProfile(
      fullName: name,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
      country: country,
      avatar: avatar,
    );

    if (response.response.statusCode == 200 && response.data.success) {
      return UserProfileModel.fromJson({
        'id': response.data.user.userId,
        'email': response.data.user.email,
        'full_name': response.data.user.fullName,
        'phone': response.data.user.phone,
        'avatar_url': response.data.user.avatarKey,
        'gender': response.data.user.gender,
        'date_of_birth': response.data.user.dateOfBirth,
        'country': response.data.user.country,
        'created_at': response.data.user.createdAt,
        'email_verified': response.data.user.isEmailVerified ?? false,
        'status': response.data.user.status ?? 'active',
      });
    }
    throw Exception('Failed to update profile');
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.changePassword(
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      if (response.response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          return;
        }
      }
      throw const AppException(message: 'Failed to change password');
    } on DioException catch (e) {
      throw appExceptionFromDio(e);
    }
  }

  Future<void> deleteAccount({required String password}) async {
    final response = await _apiClient.deleteAccount(
      data: {'password': password},
    );

    if (response.response.statusCode != 200) {
      throw Exception('Failed to delete account');
    }
  }
}
