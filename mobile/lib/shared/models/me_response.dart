import 'package:json_annotation/json_annotation.dart';

import 'register_response.dart';

part 'me_response.g.dart';

@JsonSerializable()
class MeResponse {
  const MeResponse({required this.success, required this.user});

  final bool success;
  final UserData user;

  factory MeResponse.fromJson(Map<String, dynamic> json) =>
      _$MeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MeResponseToJson(this);
}
