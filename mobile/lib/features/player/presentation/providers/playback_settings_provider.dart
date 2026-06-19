import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-tweakable presentation settings persisted across player sessions.
/// Currently: subtitle font scale, subtitle background opacity, default
/// playback speed. Read once on startup; written through small mutators.
class PlaybackSettings {
  const PlaybackSettings({
    this.subtitleFontScale = 1.0,
    this.subtitleBackgroundOpacity = 0.55,
    this.defaultSpeed = 1.0,
    this.autoPlayNextEpisode = true,
  });

  final double subtitleFontScale;
  final double subtitleBackgroundOpacity;
  final double defaultSpeed;
  final bool autoPlayNextEpisode;

  PlaybackSettings copyWith({
    double? subtitleFontScale,
    double? subtitleBackgroundOpacity,
    double? defaultSpeed,
    bool? autoPlayNextEpisode,
  }) {
    return PlaybackSettings(
      subtitleFontScale: subtitleFontScale ?? this.subtitleFontScale,
      subtitleBackgroundOpacity:
          subtitleBackgroundOpacity ?? this.subtitleBackgroundOpacity,
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      autoPlayNextEpisode: autoPlayNextEpisode ?? this.autoPlayNextEpisode,
    );
  }
}

class PlaybackSettingsNotifier extends Notifier<PlaybackSettings> {
  static const _kFontScale = 'player.subtitle.font_scale';
  static const _kBgOpacity = 'player.subtitle.bg_opacity';
  static const _kSpeed = 'player.default_speed';
  static const _kAutoPlayNext = 'player.autoplay_next_episode';

  @override
  PlaybackSettings build() {
    _hydrate();
    return const PlaybackSettings();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    state = PlaybackSettings(
      subtitleFontScale: prefs.getDouble(_kFontScale) ?? 1.0,
      subtitleBackgroundOpacity: prefs.getDouble(_kBgOpacity) ?? 0.55,
      defaultSpeed: prefs.getDouble(_kSpeed) ?? 1.0,
      autoPlayNextEpisode: prefs.getBool(_kAutoPlayNext) ?? true,
    );
  }

  Future<void> setSubtitleFontScale(double scale) async {
    state = state.copyWith(subtitleFontScale: scale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontScale, scale);
  }

  Future<void> setSubtitleBackgroundOpacity(double opacity) async {
    state = state.copyWith(subtitleBackgroundOpacity: opacity);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kBgOpacity, opacity);
  }

  Future<void> setDefaultSpeed(double speed) async {
    state = state.copyWith(defaultSpeed: speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kSpeed, speed);
  }

  Future<void> setAutoPlayNextEpisode(bool enabled) async {
    state = state.copyWith(autoPlayNextEpisode: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoPlayNext, enabled);
  }
}

final playbackSettingsProvider =
    NotifierProvider<PlaybackSettingsNotifier, PlaybackSettings>(
  PlaybackSettingsNotifier.new,
);
