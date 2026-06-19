import '../../domain/entities/user_profile.dart';

enum ProfileActionType {
  none,
  loadProfile,
  updateProfile,
  changePassword,
  deleteAccount,
}

class ProfileState {
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.actionType = ProfileActionType.none,
  });

  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final ProfileActionType actionType;

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    ProfileActionType? actionType,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      actionType: actionType ?? this.actionType,
    );
  }
}

extension ProfileStateUi on ProfileState {
  bool get loadProfileLoading =>
      actionType == ProfileActionType.loadProfile && isLoading;

  String? get loadProfileError =>
      actionType == ProfileActionType.loadProfile ? errorMessage : null;

  bool get updateProfileLoading =>
      actionType == ProfileActionType.updateProfile && isLoading;

  String? get updateProfileError =>
      actionType == ProfileActionType.updateProfile ? errorMessage : null;

  bool get changePasswordLoading =>
      actionType == ProfileActionType.changePassword && isLoading;

  String? get changePasswordError =>
      actionType == ProfileActionType.changePassword ? errorMessage : null;

  bool get deleteAccountLoading =>
      actionType == ProfileActionType.deleteAccount && isLoading;

  String? get deleteAccountError =>
      actionType == ProfileActionType.deleteAccount ? errorMessage : null;
}
