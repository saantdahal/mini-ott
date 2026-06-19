/// A resolved, playable video source returned by the backend.
sealed class PlaybackSource {
  const PlaybackSource({required this.expiresIn});

  final int expiresIn;
}

class HlsSource extends PlaybackSource {
  const HlsSource({required this.manifestUrl, required super.expiresIn});

  final String manifestUrl;
}

class Mp4Source extends PlaybackSource {
  const Mp4Source({required this.url, required super.expiresIn});

  final String url;
}
