import 'package:json_annotation/json_annotation.dart';

part 'api_error_body.g.dart';

/// Typical API error JSON: `{ "success": false, "message": "..." }`
@JsonSerializable()
class ApiErrorBody {
  const ApiErrorBody({this.success, this.message});

  final bool? success;
  final String? message;

  factory ApiErrorBody.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorBodyToJson(this);
}
