import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile> call({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? country,
    String? avatarPath,
  }) {
    return _repository.updateProfile(
      name: name,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
      country: country,
      avatarPath: avatarPath,
    );
  }
}
