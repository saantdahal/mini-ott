import 'package:json_annotation/json_annotation.dart';

import 'register_response.dart';

part 'refresh_tokens_response.g.dart';

@JsonSerializable()
class RefreshTokensResponse {
  const RefreshTokensResponse({required this.success, required this.tokens});

  final bool success;
  final Tokens tokens;

  factory RefreshTokensResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokensResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokensResponseToJson(this);
}
