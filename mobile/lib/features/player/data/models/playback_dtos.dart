import 'package:json_annotation/json_annotation.dart';

part 'playback_dtos.g.dart';

@JsonSerializable(createToJson: false)
class HlsPlaybackResponse {
  const HlsPlaybackResponse({
    this.success,
    this.message,
    this.data,
  });

  final bool? success;
  final String? message;
  final HlsPlaybackData? data;

  factory HlsPlaybackResponse.fromJson(Map<String, dynamic> json) =>
      _$HlsPlaybackResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class HlsPlaybackData {
  const HlsPlaybackData({
    this.manifestUrl,
    this.expiresIn,
    this.phase,
  });

  @JsonKey(name: 'manifest_url')
  final String? manifestUrl;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  final String? phase;

  factory HlsPlaybackData.fromJson(Map<String, dynamic> json) =>
      _$HlsPlaybackDataFromJson(json);
}

@JsonSerializable(createToJson: false)
class Mp4PlaybackResponse {
  const Mp4PlaybackResponse({
    this.success,
    this.message,
    this.data,
  });

  final bool? success;
  final String? message;
  final Mp4PlaybackData? data;

  factory Mp4PlaybackResponse.fromJson(Map<String, dynamic> json) =>
      _$Mp4PlaybackResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class Mp4PlaybackData {
  const Mp4PlaybackData({this.url, this.expiresIn});

  final String? url;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;

  factory Mp4PlaybackData.fromJson(Map<String, dynamic> json) =>
      _$Mp4PlaybackDataFromJson(json);
}
