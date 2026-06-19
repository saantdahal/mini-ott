import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/playback_settings_provider.dart';
import '../theme/ott_player_tokens.dart';
import '_sheet_chrome.dart';

/// Lists subtitle tracks pulled from the HLS manifest. Also lets the user
/// tweak font size + background opacity, persisted via `PlaybackSettings`.
/// [onPicked] reports the human-readable label of the chosen track ("Off"
/// when subtitles are disabled) so the bottom-bar label can mirror it.
class SubtitleSheet extends ConsumerWidget {
  const SubtitleSheet({
    super.key,
    required this.controller,
    required this.onPicked,
  });

  final BetterPlayerController controller;
  final ValueChanged<String> onPicked;

  String _labelFor(BetterPlayerSubtitlesSource s) {
    final name = s.name;
    if (name != null && name.isNotEmpty) return name;
    final type = s.type;
    if (type == BetterPlayerSubtitlesSourceType.none) return 'Off';
    return 'Subtitle';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(playbackSettingsProvider);
    final settingsCtl = ref.read(playbackSettingsProvider.notifier);
    final sources = controller.betterPlayerSubtitlesSourceList;
    final selected = controller.betterPlayerSubtitlesSource;
    return PlayerSheetScaffold(
      title: 'Subtitles',
      subtitle: sources.isEmpty
          ? 'No subtitle tracks for this episode.'
          : 'Pick a track and tweak appearance.',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetOptionTile(
              label: 'Off',
              selected: selected == null ||
                  selected.type == BetterPlayerSubtitlesSourceType.none,
              onTap: () {
                final off = sources.firstWhere(
                  (s) => s.type == BetterPlayerSubtitlesSourceType.none,
                  orElse: () => BetterPlayerSubtitlesSource(
                    type: BetterPlayerSubtitlesSourceType.none,
                  ),
                );
                try {
                  controller.setupSubtitleSource(off);
                } catch (_) {}
                onPicked('Off');
                Navigator.of(context).maybePop();
              },
            ),
            ...sources
                .where((s) => s.type != BetterPlayerSubtitlesSourceType.none)
                .map(
                  (s) => SheetOptionTile(
                    label: _labelFor(s),
                    selected: identical(selected, s),
                    onTap: () {
                      try {
                        controller.setupSubtitleSource(s);
                      } catch (_) {}
                      onPicked(_labelFor(s));
                      Navigator.of(context).maybePop();
                    },
                  ),
                ),
            if (sources.isNotEmpty) ...[
              const Divider(color: Colors.white10, height: 24),
              _SettingSlider(
                label: 'Font size',
                value: settings.subtitleFontScale,
                min: 0.7,
                max: 1.6,
                onChanged: settingsCtl.setSubtitleFontScale,
              ),
              _SettingSlider(
                label: 'Background opacity',
                value: settings.subtitleBackgroundOpacity,
                min: 0,
                max: 1,
                onChanged: settingsCtl.setSubtitleBackgroundOpacity,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  const _SettingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                value.toStringAsFixed(2),
                style: const TextStyle(
                  color: OttPlayerTokens.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: OttPlayerTokens.accent,
              inactiveTrackColor: Colors.white24,
              thumbColor: OttPlayerTokens.accentSoft,
              overlayColor: OttPlayerTokens.accent.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
