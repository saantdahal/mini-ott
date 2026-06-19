import 'package:flutter/material.dart';

import '../theme/ott_player_tokens.dart';

/// Wraps [child] with the standard player fade + ignore-pointer behaviour. Used
/// for top/bottom/center chrome so all overlays animate identically.
class FadeOverlay extends StatelessWidget {
  const FadeOverlay({
    super.key,
    required this.visible,
    required this.child,
    this.duration = OttPlayerTokens.fadeDuration,
  });

  final bool visible;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: duration,
        opacity: visible ? 1 : 0,
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }
}
