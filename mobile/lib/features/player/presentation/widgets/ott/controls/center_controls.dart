import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '../overlays/buffering_indicator.dart';

/// Center cluster: previous-episode, play/pause, next-episode. Each button
/// fades to invisible when its corresponding callback is null (e.g. there's
/// no previous episode). The play/pause icon morphs via [AnimatedSwitcher].
///
/// Listens to the underlying `VideoPlayerController` so the play/pause state
/// updates without rebuilding the rest of the chrome.
class CenterControls extends StatelessWidget {
  const CenterControls({
    super.key,
    required this.controller,
    required this.bufferingVisible,
    required this.onPrevious,
    required this.onNext,
    required this.onTogglePlay,
  });

  final BetterPlayerController controller;
  final bool bufferingVisible;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onTogglePlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SideButton(
            icon: Icons.skip_previous_rounded,
            onPressed: onPrevious,
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 84,
            height: 84,
            child: Center(
              child: bufferingVisible
                  ? const BufferingIndicator(size: 56)
                  : _PlayPauseButton(
                      controller: controller,
                      onTap: onTogglePlay,
                    ),
            ),
          ),
          const SizedBox(width: 24),
          _SideButton(
            icon: Icons.skip_next_rounded,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.25,
      child: IconButton(
        iconSize: 36,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.controller, required this.onTap});

  final BetterPlayerController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inner = controller.videoPlayerController;
    if (inner == null) {
      return _Glyph(icon: Icons.play_arrow_rounded, onTap: onTap);
    }
    return ValueListenableBuilder(
      valueListenable: inner,
      builder: (context, value, _) {
        final isPlaying = value.isPlaying;
        return _Glyph(
          icon: isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          onTap: onTap,
        );
      },
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.42),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 78,
          height: 78,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              icon,
              key: ValueKey(icon),
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
      ),
    );
  }
}
