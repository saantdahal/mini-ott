import 'package:json_annotation/json_annotation.dart';

import 'coin_package_model.dart';

part 'coin_packages_response.g.dart';

@JsonSerializable()
class CoinPackagesResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'result')
  final List<CoinPackageModel> result;

  const CoinPackagesResponse({
    required this.success,
    required this.message,
    required this.result,
  });

  factory CoinPackagesResponse.fromJson(Map<String, dynamic> json) =>
      _$CoinPackagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CoinPackagesResponseToJson(this);
}
