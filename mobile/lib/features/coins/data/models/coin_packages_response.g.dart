// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_packages_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinPackagesResponse _$CoinPackagesResponseFromJson(
  Map<String, dynamic> json,
) => CoinPackagesResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  result: (json['result'] as List<dynamic>)
      .map((e) => CoinPackageModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CoinPackagesResponseToJson(
  CoinPackagesResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'result': instance.result,
};
