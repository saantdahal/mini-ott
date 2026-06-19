import 'package:flutter/material.dart';

import '../theme/ott_player_tokens.dart';

/// "Skip Intro" pill, anchored to the bottom-right above the controls bar.
/// Visible only when the current item exposes intro markers AND the playhead
/// is inside that range. Fully data-driven — passing `null` for either marker
/// hides the button forever, so this widget costs nothing for items the API
/// hasn't annotated yet.
class SkipIntroButton extends StatelessWidget {
  const SkipIntroButton({
    super.key,
    required this.position,
    required this.introStart,
    required this.introEnd,
    required this.onPressed,
  });

  final Duration position;
  final Duration? introStart;
  final Duration? introEnd;
  final VoidCallback onPressed;

  bool get _shouldShow {
    final s = introStart;
    final e = introEnd;
    if (s == null || e == null) return false;
    if (e <= s) return false;
    return position >= s && position <= e;
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 24, bottom: 90),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: OttPlayerTokens.elevatedSurface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.skip_next_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Skip Intro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
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
