import '../entities/watch_progress.dart';

/// Stores per-item playback progress for continue-watching. The current
/// implementation is local-only; a future server-backed impl can replace it
/// without changing any callers.
abstract class WatchProgressRepository {
  Future<WatchProgress?> get(String id);
  Future<void> save(WatchProgress progress);
  Future<void> remove(String id);
}
