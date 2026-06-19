import 'package:flutter/material.dart';

import '../theme/ott_player_tokens.dart';
import '_sheet_chrome.dart';

/// Top-level settings entry sheet — each row launches its own dedicated sheet.
/// Kept thin so the heavy sheets (quality / subtitles) stay lazy.
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    super.key,
    required this.speedLabel,
    required this.qualityLabel,
    required this.subtitleLabel,
    required this.audioLabel,
    required this.onSpeed,
    required this.onQuality,
    required this.onSubtitles,
    required this.onAudio,
    this.autoPlayNext,
    this.onToggleAutoPlayNext,
  });

  final String speedLabel;
  final String qualityLabel;
  final String subtitleLabel;
  final String audioLabel;
  final VoidCallback onSpeed;
  final VoidCallback onQuality;
  final VoidCallback onSubtitles;
  final VoidCallback onAudio;

  /// When non-null, the sheet renders an "Auto-play next episode" toggle row.
  /// Both fields must be supplied together; the host hides the row entirely
  /// for non-series content (or the final episode of a season) by leaving
  /// these null.
  final bool? autoPlayNext;
  final ValueChanged<bool>? onToggleAutoPlayNext;

  @override
  Widget build(BuildContext context) {
    final showAutoPlay = autoPlayNext != null && onToggleAutoPlayNext != null;
    return PlayerSheetScaffold(
      title: 'Player settings',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAutoPlay)
            _ToggleRow(
              icon: Icons.skip_next_rounded,
              title: 'Auto-play next episode',
              value: autoPlayNext!,
              onChanged: onToggleAutoPlayNext!,
            ),
          _Row(
            icon: Icons.speed_rounded,
            title: 'Playback speed',
            value: speedLabel,
            onTap: () {
              Navigator.of(context).maybePop();
              onSpeed();
            },
          ),
          _Row(
            icon: Icons.high_quality_rounded,
            title: 'Quality',
            value: qualityLabel,
            onTap: () {
              Navigator.of(context).maybePop();
              onQuality();
            },
          ),
          _Row(
            icon: Icons.closed_caption_rounded,
            title: 'Subtitles',
            value: subtitleLabel,
            onTap: () {
              Navigator.of(context).maybePop();
              onSubtitles();
            },
          ),
          _Row(
            icon: Icons.graphic_eq_rounded,
            title: 'Audio',
            value: audioLabel,
            onTap: () {
              Navigator.of(context).maybePop();
              onAudio();
            },
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeThumbColor: OttPlayerTokens.accentSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: OttPlayerTokens.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: OttPlayerTokens.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
