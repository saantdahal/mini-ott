class HlsPlaybackEntity {
  const HlsPlaybackEntity({
    this.manifestUrl,
    this.baseUrl,
    this.expiresInSeconds,
    this.phase,
  });

  final String? manifestUrl;
  final String? baseUrl;
  final int? expiresInSeconds;
  final String? phase;
}
