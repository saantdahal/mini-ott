class Livestream {
  final String id;
  final String title;
  final String description;
  final String streamer;
  final String streamerAvatar;
  final String videoUrl;
  final String quality;
  final int viewerCount;
  final bool isLive;
  final DateTime startedAt;
  final List<String> categories;

  const Livestream({
    required this.id,
    required this.title,
    required this.description,
    required this.streamer,
    required this.streamerAvatar,
    required this.videoUrl,
    required this.quality,
    required this.viewerCount,
    required this.isLive,
    required this.startedAt,
    required this.categories,
  });

  Livestream copyWith({
    String? id,
    String? title,
    String? description,
    String? streamer,
    String? streamerAvatar,
    String? videoUrl,
    String? quality,
    int? viewerCount,
    bool? isLive,
    DateTime? startedAt,
    List<String>? categories,
  }) {
    return Livestream(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      streamer: streamer ?? this.streamer,
      streamerAvatar: streamerAvatar ?? this.streamerAvatar,
      videoUrl: videoUrl ?? this.videoUrl,
      quality: quality ?? this.quality,
      viewerCount: viewerCount ?? this.viewerCount,
      isLive: isLive ?? this.isLive,
      startedAt: startedAt ?? this.startedAt,
      categories: categories ?? this.categories,
    );
  }

  @override
  String toString() =>
      'Livestream(id: $id, title: $title, streamer: $streamer)';
}
