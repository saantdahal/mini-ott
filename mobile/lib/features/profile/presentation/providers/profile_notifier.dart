import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../../data/datasources/mock_profile_data_source.dart';
import '../../di/profile_di.dart';
import 'profile_state.dart';

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> loadProfile() async {
    final getUserProfileUseCase = ref.read(getUserProfileUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      actionType: ProfileActionType.loadProfile,
    );

    try {
      final profile = await getUserProfileUseCase.call();
      state = state.copyWith(
        isLoading: false,
        profile: profile,
        clearError: true,
        clearSuccess: true,
        actionType: ProfileActionType.loadProfile,
      );
    } catch (e) {
      // Use mock/fallback profile data when API fails
      state = state.copyWith(
        isLoading: false,
        profile: MockUserProfile.fallbackProfile,
        errorMessage: 'Using cached profile. ${mapErrorToUserMessage(e)}',
        actionType: ProfileActionType.loadProfile,
      );
    }
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? country,
    String? avatarPath,
  }) async {
    final updateProfileUseCase = ref.read(updateProfileUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      actionType: ProfileActionType.updateProfile,
    );

    try {
      final updatedProfile = await updateProfileUseCase.call(
        name: name,
        phone: phone,
        gender: gender,
        dateOfBirth: dateOfBirth,
        country: country,
        avatarPath: avatarPath,
      );
      state = state.copyWith(
        isLoading: false,
        profile: updatedProfile,
        clearError: true,
        actionType: ProfileActionType.updateProfile,
        successMessage: 'Profile updated successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: ProfileActionType.updateProfile,
      );
    }
  }

  void clearFeedback() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final changePasswordUseCase = ref.read(changePasswordUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      actionType: ProfileActionType.changePassword,
    );

    try {
      await changePasswordUseCase.call(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        actionType: ProfileActionType.changePassword,
        successMessage: 'Password changed successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: ProfileActionType.changePassword,
      );
    }
  }

  Future<void> deleteAccount({required String password}) async {
    final deleteAccountUseCase = ref.read(deleteAccountUseCaseProvider);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
      actionType: ProfileActionType.deleteAccount,
    );

    try {
      await deleteAccountUseCase.call(password: password);
      state = state.copyWith(
        isLoading: false,
        profile: null,
        clearError: true,
        actionType: ProfileActionType.deleteAccount,
        successMessage: 'Account deleted successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
        actionType: ProfileActionType.deleteAccount,
      );
    }
  }
}
