import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

class ProfileMapper {
  static UserProfile toDomain(UserProfileModel model) {
    return UserProfile(
      id: model.id,
      email: model.email,
      name: model.name,
      phone: model.phone,
      avatarUrl: model.avatarUrl,
      gender: model.gender,
      dateOfBirth: model.dateOfBirth,
      country: model.country,
      createdAt: model.createdAt != null
          ? DateTime.tryParse(model.createdAt!)
          : null,
      isEmailVerified: model.isEmailVerified,
      status: model.status,
    );
  }

  static UserProfileModel toModel(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      gender: entity.gender,
      dateOfBirth: entity.dateOfBirth,
      country: entity.country,
      createdAt: entity.createdAt?.toIso8601String(),
      isEmailVerified: entity.isEmailVerified,
      status: entity.status,
    );
  }
}
