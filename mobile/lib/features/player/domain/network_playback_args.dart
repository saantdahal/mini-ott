/// Route `extra` for [NetworkVideoPlayerScreen].
class NetworkPlaybackArgs {
  const NetworkPlaybackArgs({
    required this.url,
    required this.displayTitle,
    this.episodeLabel,
    this.progressKey,
  });

  final String url;
  final String displayTitle;

  /// Optional sub-line shown in the player's top bar.
  final String? episodeLabel;

  /// Optional stable id used for continue-watching when the caller has one.
  /// Falls back to a hash of [url] inside the player when absent.
  final String? progressKey;
}
