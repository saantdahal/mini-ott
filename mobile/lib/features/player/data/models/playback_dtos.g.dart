// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HlsPlaybackResponse _$HlsPlaybackResponseFromJson(Map<String, dynamic> json) =>
    HlsPlaybackResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : HlsPlaybackData.fromJson(json['data'] as Map<String, dynamic>),
    );

HlsPlaybackData _$HlsPlaybackDataFromJson(Map<String, dynamic> json) =>
    HlsPlaybackData(
      manifestUrl: json['manifest_url'] as String?,
      expiresIn: (json['expires_in'] as num?)?.toInt(),
      phase: json['phase'] as String?,
    );

Mp4PlaybackResponse _$Mp4PlaybackResponseFromJson(Map<String, dynamic> json) =>
    Mp4PlaybackResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : Mp4PlaybackData.fromJson(json['data'] as Map<String, dynamic>),
    );

Mp4PlaybackData _$Mp4PlaybackDataFromJson(Map<String, dynamic> json) =>
    Mp4PlaybackData(
      url: json['url'] as String?,
      expiresIn: (json['expires_in'] as num?)?.toInt(),
    );
