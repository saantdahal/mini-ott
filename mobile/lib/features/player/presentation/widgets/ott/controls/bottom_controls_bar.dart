import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '../progress/modern_progress_bar.dart';
import '../progress/time_label.dart';
import '../theme/ott_player_tokens.dart';

class BottomControlsBar extends StatefulWidget {
  const BottomControlsBar({
    super.key,
    required this.controller,
    required this.fitLabel,
    required this.speedLabel,
    required this.qualityLabel,
    required this.subtitleLabel,
    required this.episodeListVisible,
    required this.pipAvailable,
    required this.onCycleFit,
    required this.onTapSubtitles,
    required this.onTapSpeed,
    required this.onTapQuality,
    required this.onTapEpisodes,
    required this.onTapPip,
    required this.onScrubStart,
    required this.onScrubEnd,
  });

  final BetterPlayerController controller;
  final String fitLabel;
  final String speedLabel;
  final String qualityLabel;
  final String subtitleLabel;
  final bool episodeListVisible;
  final bool pipAvailable;
  final VoidCallback onCycleFit;
  final VoidCallback onTapSubtitles;
  final VoidCallback onTapSpeed;
  final VoidCallback onTapQuality;
  final VoidCallback onTapEpisodes;
  final VoidCallback onTapPip;
  final VoidCallback onScrubStart;
  final VoidCallback onScrubEnd;

  @override
  State<BottomControlsBar> createState() => _BottomControlsBarState();
}

class _BottomControlsBarState extends State<BottomControlsBar> {
  // Shared between the progress bar (writer) and the time label (reader) so
  // the timer previews the seek target while the user drags.
  final ValueNotifier<double?> _scrubFraction = ValueNotifier<double?>(null);

  @override
  void dispose() {
    _scrubFraction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: OttPlayerTokens.bottomScrim),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModernProgressBar(
                controller: widget.controller,
                onScrubStart: widget.onScrubStart,
                onScrubEnd: widget.onScrubEnd,
                scrubFraction: _scrubFraction,
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                // mainAxisSize.min is required: a horizontal scroll view
                // gives its child unbounded width, and the default
                // MainAxisSize.max would try to take all of it.
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TimeLabel(
                      controller: widget.controller,
                      scrubFraction: _scrubFraction,
                    ),
                    const SizedBox(width: 8),
                    if (widget.episodeListVisible)
                      _ChromeButton(
                        icon: Icons.playlist_play_rounded,
                        label: 'Episodes',
                        onTap: widget.onTapEpisodes,
                      ),
                    _ChromeButton(
                      icon: Icons.closed_caption_rounded,
                      label: widget.subtitleLabel,
                      onTap: widget.onTapSubtitles,
                    ),
                    _ChromeButton(
                      icon: Icons.speed_rounded,
                      label: widget.speedLabel,
                      onTap: widget.onTapSpeed,
                    ),
                    _ChromeButton(
                      icon: Icons.high_quality_rounded,
                      label: widget.qualityLabel,
                      onTap: widget.onTapQuality,
                    ),
                    if (widget.pipAvailable)
                      _ChromeButton(
                        icon: Icons.picture_in_picture_alt_rounded,
                        label: 'PiP',
                        onTap: widget.onTapPip,
                      ),
                    _ChromeButton(
                      icon: Icons.aspect_ratio_rounded,
                      label: widget.fitLabel,
                      onTap: widget.onCycleFit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChromeButton extends StatelessWidget {
  const _ChromeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: OttPlayerTokens.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
