import '../repositories/profile_repository.dart';

class ChangePasswordUseCase {
  ChangePasswordUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
