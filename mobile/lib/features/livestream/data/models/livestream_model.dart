import "../../domain/entities/livestream.dart";

class LivestreamModel extends Livestream {
  const LivestreamModel({
    required super.id,
    required super.title,
    required super.description,
    required super.streamer,
    required super.streamerAvatar,
    required super.videoUrl,
    required super.quality,
    required super.viewerCount,
    required super.isLive,
    required super.startedAt,
    required super.categories,
  });

  factory LivestreamModel.fromJson(Map<String, dynamic> json) {
    return LivestreamModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? "",
      streamer: json['streamer'],
      streamerAvatar: json['streamer_avatar'] ?? "",
      videoUrl: json['video_url'],
      quality: json['quality'] ?? "1080p",
      viewerCount: json['viewer_count'] ?? 0,
      isLive: json['is_live'] ?? true,
      startedAt: DateTime.parse(json['started_at']),
      categories: List<String>.from(json['categories'] ?? []),
    );
  }
}
