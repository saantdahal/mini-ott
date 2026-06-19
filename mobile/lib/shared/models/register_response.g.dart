// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: json['user'] == null
          ? null
          : UserData.fromJson(json['user'] as Map<String, dynamic>),
      tokens: json['tokens'] == null
          ? null
          : Tokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'user': instance.user,
      'tokens': instance.tokens,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
  userId: json['user_id'] as String,
  fullName: json['full_name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  authProvider: json['auth_provider'] as String?,
  avatarKey: json['avatar_key'] as String?,
  role: json['role'] as String?,
  gender: json['gender'] as String?,
  dateOfBirth: json['date_of_birth'] as String?,
  country: json['country'] as String?,
  isEmailVerified: json['is_email_verified'] as bool?,
  status: json['status'] as String?,
  lastLoginAt: json['last_login_at'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
  'user_id': instance.userId,
  'full_name': instance.fullName,
  'email': instance.email,
  'phone': instance.phone,
  'auth_provider': instance.authProvider,
  'avatar_key': instance.avatarKey,
  'role': instance.role,
  'gender': instance.gender,
  'date_of_birth': instance.dateOfBirth,
  'country': instance.country,
  'is_email_verified': instance.isEmailVerified,
  'status': instance.status,
  'last_login_at': instance.lastLoginAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

Tokens _$TokensFromJson(Map<String, dynamic> json) => Tokens(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$TokensToJson(Tokens instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
};
