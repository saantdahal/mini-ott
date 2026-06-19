/// Resume position for a single playable item (movie content or episode).
///
/// `id` is whichever stable identifier the caller has — typically the
/// `episodeId`, falling back to `contentId` for films. Persisted locally for
/// continue-watching; the same shape is intended to round-trip with the
/// server's `watch_history` table when that endpoint lands.
class WatchProgress {
  const WatchProgress({
    required this.id,
    required this.positionMs,
    required this.durationMs,
    required this.updatedAtMs,
  });

  final String id;
  final int positionMs;
  final int durationMs;
  final int updatedAtMs;

  Duration get position => Duration(milliseconds: positionMs);
  Duration get duration => Duration(milliseconds: durationMs);

  double get fraction =>
      durationMs <= 0 ? 0 : (positionMs / durationMs).clamp(0.0, 1.0);

  /// Don't auto-resume right at the start or when essentially finished.
  bool get isResumable {
    if (durationMs <= 0) return positionMs > 5000;
    final f = fraction;
    return positionMs > 5000 && f < 0.95;
  }

  WatchProgress copyWith({int? positionMs, int? durationMs, int? updatedAtMs}) {
    return WatchProgress(
      id: id,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'positionMs': positionMs,
    'durationMs': durationMs,
    'updatedAtMs': updatedAtMs,
  };

  factory WatchProgress.fromJson(Map<String, dynamic> json) => WatchProgress(
    id: json['id'] as String,
    positionMs: (json['positionMs'] as num).toInt(),
    durationMs: (json['durationMs'] as num).toInt(),
    updatedAtMs: (json['updatedAtMs'] as num).toInt(),
  );
}
