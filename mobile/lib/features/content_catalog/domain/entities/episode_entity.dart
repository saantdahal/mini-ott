class EpisodeEntity {
  const EpisodeEntity({
    required this.id,
    required this.contentId,
    this.seasonId,
    required this.episodeNumber,
    required this.title,
    this.description,
    this.shortDescription,
    this.thumbnailUrl,
    this.bannerUrl,
    this.streamManifestKey,
    this.durationSeconds,
    this.accessType,
    this.requiredCoins,
    this.status,
    this.releaseDate,
  });

  final String id;
  final String contentId;
  final String? seasonId;
  final int episodeNumber;
  final String title;
  final String? description;
  final String? shortDescription;
  final String? thumbnailUrl;
  final String? bannerUrl;

  /// Raw `stream_manifest_key` from the API. Signal-only — the playable URL
  /// is resolved on demand by the player feature.
  final String? streamManifestKey;

  final int? durationSeconds;
  final String? accessType;
  final int? requiredCoins;
  final String? status;
  final String? releaseDate;

  bool get isFree => (accessType ?? 'free') == 'free';

  bool get hasManifestKey =>
      streamManifestKey != null && streamManifestKey!.isNotEmpty;

  String get codeLabel => 'E$episodeNumber: $title';
}
