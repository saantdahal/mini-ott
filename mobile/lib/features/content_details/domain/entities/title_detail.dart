class CastMember {
  const CastMember({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String avatarUrl;
}

class TitleEpisode {
  const TitleEpisode({
    required this.index,
    required this.title,
    required this.duration,
    required this.thumbnailUrl,
    required this.isFree,
    this.coinCost,
    this.episodeId,
    this.streamManifestKey,
    this.videoUploadId,
  });

  final int index;
  final String title;
  final String duration;
  final String thumbnailUrl;
  final bool isFree;
  final int? coinCost;

  /// API `episode_id` when mapped from catalog.
  final String? episodeId;

  /// Raw `stream_manifest_key` from the API. Used only as a signal for
  /// whether HLS playback is available — the actual playable URL is fetched
  /// on demand from `/api/stream/{contentId}/hls`.
  final String? streamManifestKey;

  /// Direct `video_upload_id` from the API when the app should resolve the
  /// playback URL through the upload-aware HLS endpoint.
  final String? videoUploadId;

  bool get hasManifestKey =>
      streamManifestKey != null && streamManifestKey!.isNotEmpty;

  String get codeLabel => 'E$index: $title';
}

class TitleDetail {
  const TitleDetail({
    required this.id,
    required this.title,
    required this.heroImageUrl,
    required this.genres,
    required this.starRating,
    required this.episodeCountLabel,
    required this.isSeries,
    required this.synopsis,
    required this.cast,
    required this.seasonIds,
    required this.seasonTitlesById,
    required this.episodesBySeasonId,
    required this.unlockCoinCost,
    required this.totalEpisodesForUnlock,
    this.streamManifestKey,
    this.videoUploadId,
  });

  final String id;
  final String title;
  final String heroImageUrl;
  final List<String> genres;
  final double starRating;
  final String episodeCountLabel;
  final bool isSeries;
  final String synopsis;
  final List<CastMember> cast;
  final List<String> seasonIds;

  /// season_id → API `title` (or generated label); keys align with [seasonIds].
  final Map<String, String> seasonTitlesById;
  final Map<String, List<TitleEpisode>> episodesBySeasonId;
  final int unlockCoinCost;
  final int totalEpisodesForUnlock;

  /// Raw content-level `stream_manifest_key` (e.g. for a feature film).
  /// Signal-only — the playable URL is resolved by the player feature.
  final String? streamManifestKey;

  /// Content-level `video_upload_id` when the backend wants the app to resolve
  /// playback via `/api/stream/{videoUploadId}/hls` or upload play-url fallback.
  final String? videoUploadId;

  bool get hasManifestKey =>
      streamManifestKey != null && streamManifestKey!.isNotEmpty;

  List<TitleEpisode> episodesForSeason(String seasonId) {
    return episodesBySeasonId[seasonId] ?? const [];
  }
}
