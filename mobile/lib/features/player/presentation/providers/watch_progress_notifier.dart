import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/player_di.dart';
import '../../domain/entities/watch_progress.dart';

/// Thin Riverpod surface around `WatchProgressRepository`. Stateless on the
/// notifier side — every call hits the repository directly. The player owns
/// the per-session in-memory copy of progress; persistence is the only
/// concern this notifier addresses.
class WatchProgressController {
  WatchProgressController(this._ref);

  final Ref _ref;

  Future<WatchProgress?> read(String key) {
    return _ref.read(watchProgressRepositoryProvider).get(key);
  }

  Future<void> save({
    required String key,
    required Duration position,
    required Duration duration,
  }) async {
    if (position <= Duration.zero) return;
    final progress = WatchProgress(
      id: key,
      positionMs: position.inMilliseconds,
      durationMs: duration.inMilliseconds,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _ref.read(watchProgressRepositoryProvider).save(progress);
  }

  Future<void> clear(String key) {
    return _ref.read(watchProgressRepositoryProvider).remove(key);
  }
}

final watchProgressControllerProvider = Provider<WatchProgressController>(
  WatchProgressController.new,
);
