import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  GetUserProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserProfile> call() {
    return _repository.getUserProfile();
  }
}
