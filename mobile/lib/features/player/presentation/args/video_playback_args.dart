import '../../../content_details/domain/entities/title_detail.dart';

/// Route `extra` for the upload-aware player. Resolves a playable source
/// (HLS or MP4) on demand via [PlaybackRepository], so callers do not need
/// to know which format will be served.
///
/// When [playlist] is non-null the player surfaces the episode list bottom
/// sheet and the next-episode autoplay card. For films, leave [playlist] null.
class VideoUploadPlaybackArgs {
  const VideoUploadPlaybackArgs({
    required this.contentId,
    required this.displayTitle,
    required this.hasManifestKey,
    this.episodeId,
    this.uploadId,
    this.episodeLabel,
    this.playlist,
    this.currentIndex = 0,
  });

  final String contentId;
  final String displayTitle;
  final bool hasManifestKey;
  final String? episodeId;
  final String? uploadId;

  /// Optional sub-line shown in the player's top bar (e.g. `S1 · E3 · Pilot`).
  final String? episodeLabel;

  /// Full season episode list for queue-aware features. Null for movies.
  final List<TitleEpisode>? playlist;

  /// Index in [playlist] of the currently-playing episode.
  final int currentIndex;

  bool get hasPlaylist =>
      playlist != null && playlist!.isNotEmpty && playlist!.length > 1;

  /// Stable id used as the watch-progress key. Falls back from episode → upload
  /// → content so a film without an episode still resumes correctly.
  String get progressKey {
    final ep = episodeId;
    if (ep != null && ep.isNotEmpty) return 'episode:$ep';
    final up = uploadId;
    if (up != null && up.isNotEmpty) return 'upload:$up';
    return 'content:$contentId';
  }
}
