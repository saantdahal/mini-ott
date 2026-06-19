// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_tokens_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshTokensResponse _$RefreshTokensResponseFromJson(
  Map<String, dynamic> json,
) => RefreshTokensResponse(
  success: json['success'] as bool,
  tokens: Tokens.fromJson(json['tokens'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RefreshTokensResponseToJson(
  RefreshTokensResponse instance,
) => <String, dynamic>{'success': instance.success, 'tokens': instance.tokens};
