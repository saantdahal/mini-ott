// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiErrorBody _$ApiErrorBodyFromJson(Map<String, dynamic> json) => ApiErrorBody(
  success: json['success'] as bool?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$ApiErrorBodyToJson(ApiErrorBody instance) =>
    <String, dynamic>{'success': instance.success, 'message': instance.message};
