import 'package:dio/dio.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../mappers/profile_mapper.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    required ProfileLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;

  @override
  Future<UserProfile> getUserProfile() async {
    try {
      final model = await _remoteDataSource.getUserProfile();
      await _localDataSource.saveProfile(model);
      return ProfileMapper.toDomain(model);
    } catch (e) {
      final cachedModel = await _localDataSource.getProfile();
      if (cachedModel != null) {
        return ProfileMapper.toDomain(cachedModel);
      }
      rethrow;
    }
  }

  @override
  Future<UserProfile> updateProfile({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? country,
    String? avatarPath,
  }) async {
    final model = await _remoteDataSource.updateProfile(
      name: name,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
      country: country,
      avatar: avatarPath != null ? await _prepareAvatar(avatarPath) : null,
    );
    await _localDataSource.saveProfile(model);
    return ProfileMapper.toDomain(model);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) =>
      _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  @override
  Future<void> deleteAccount({required String password}) =>
      _remoteDataSource.deleteAccount(password: password);

  Future<dynamic> _prepareAvatar(String avatarPath) async {
    try {
      return await MultipartFile.fromFile(avatarPath);
    } catch (_) {
      return null;
    }
  }
}
