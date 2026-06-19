import 'package:json_annotation/json_annotation.dart';

import 'wallet_model.dart';

part 'wallet_response.g.dart';

@JsonSerializable()
class WalletResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'data')
  final WalletModel data;

  const WalletResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WalletResponseToJson(this);
}
