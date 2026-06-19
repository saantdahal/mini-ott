import 'package:json_annotation/json_annotation.dart';

part 'register_response.g.dart';

@JsonSerializable()
class RegisterResponse {
  const RegisterResponse({
    required this.success,
    required this.message,
    this.user,
    this.tokens,
  });

  final bool success;
  final String message;
  final UserData? user;
  final Tokens? tokens;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

@JsonSerializable()
class UserData {
  const UserData({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    this.authProvider,
    this.avatarKey,
    this.role,
    this.gender,
    this.dateOfBirth,
    this.country,
    this.isEmailVerified,
    this.status,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'full_name')
  final String fullName;

  final String email;
  final String? phone;

  @JsonKey(name: 'auth_provider')
  final String? authProvider;

  @JsonKey(name: 'avatar_key')
  final String? avatarKey;

  final String? role;
  final String? gender;

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;

  final String? country;

  @JsonKey(name: 'is_email_verified')
  final bool? isEmailVerified;

  final String? status;

  @JsonKey(name: 'last_login_at')
  final String? lastLoginAt;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

@JsonSerializable()
class Tokens {
  const Tokens({required this.accessToken, required this.refreshToken});

  @JsonKey(name: 'accessToken')
  final String accessToken;

  @JsonKey(name: 'refreshToken')
  final String refreshToken;

  factory Tokens.fromJson(Map<String, dynamic> json) => _$TokensFromJson(json);

  Map<String, dynamic> toJson() => _$TokensToJson(this);
}
