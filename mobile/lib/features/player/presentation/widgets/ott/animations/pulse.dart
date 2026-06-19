import 'package:flutter/material.dart';

/// One-shot fade+scale pulse used when play/pause is toggled. Driven by a
/// passed-in [AnimationController] so the parent can reuse a single controller
/// instead of recreating one per pulse (cheaper in this hot UI).
class Pulse extends StatelessWidget {
  const Pulse({
    super.key,
    required this.controller,
    required this.child,
  });

  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, c) {
        final t = controller.value;
        if (t == 0) return const SizedBox.shrink();
        // Fade-in/out via reverse-bell, slight scale-up.
        final fade = (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
        final scale = 0.85 + 0.25 * fade;
        return Opacity(
          opacity: fade,
          child: Transform.scale(scale: scale, child: c),
        );
      },
      child: child,
    );
  }
}
