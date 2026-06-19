import '../entities/register_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<RegisterResult> call({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? country,
    String? gender,
    String? dateOfBirth,
    String? avatarPath,
  }) {
    return _authRepository.register(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      country: country,
      gender: gender,
      dateOfBirth: dateOfBirth,
      avatarPath: avatarPath,
    );
  }
}
