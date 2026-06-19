import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/watch_progress.dart';
import '../../domain/repositories/watch_progress_repository.dart';

/// Persists [WatchProgress] in `SharedPreferences` under a single map key.
/// Lazy-loads on first access; writes are awaited so they survive the player
/// being disposed mid-tear-down.
class WatchProgressLocalDataSource implements WatchProgressRepository {
  WatchProgressLocalDataSource();

  static const _kPrefsKey = 'player.watch_progress.v1';
  Map<String, WatchProgress>? _cache;

  Future<Map<String, WatchProgress>> _load() async {
    if (_cache != null) return _cache!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsKey);
    if (raw == null || raw.isEmpty) {
      return _cache = <String, WatchProgress>{};
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return _cache = {
        for (final entry in decoded.entries)
          entry.key: WatchProgress.fromJson(
            (entry.value as Map).cast<String, dynamic>(),
          ),
      };
    } catch (_) {
      // Corrupt blob — drop and start fresh rather than throwing into
      // the player init path.
      return _cache = <String, WatchProgress>{};
    }
  }

  Future<void> _flush() async {
    final cache = _cache;
    if (cache == null) return;
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      for (final entry in cache.entries) entry.key: entry.value.toJson(),
    });
    await prefs.setString(_kPrefsKey, encoded);
  }

  @override
  Future<WatchProgress?> get(String id) async {
    final cache = await _load();
    return cache[id];
  }

  @override
  Future<void> save(WatchProgress progress) async {
    final cache = await _load();
    cache[progress.id] = progress;
    await _flush();
  }

  @override
  Future<void> remove(String id) async {
    final cache = await _load();
    if (cache.remove(id) != null) {
      await _flush();
    }
  }
}
