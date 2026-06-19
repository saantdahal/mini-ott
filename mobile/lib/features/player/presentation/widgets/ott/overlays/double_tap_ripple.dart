import 'package:flutter/material.dart';

import '../theme/ott_player_tokens.dart';

/// Snapshot of the active double-tap-seek ripple. Held in the parent's state
/// and bumped on every chained tap so the badge accumulates (+10 → +20 → …).
class RippleState {
  const RippleState({
    required this.visible,
    required this.forward,
    required this.skipSeconds,
    required this.bumpKey,
  });

  final bool visible;
  final bool forward;
  final int skipSeconds;
  final int bumpKey;

  static const hidden = RippleState(
    visible: false,
    forward: true,
    skipSeconds: 0,
    bumpKey: 0,
  );
}

/// Half-screen ripple + skip badge. Rendered for both sides; the [forward]
/// flag drives which half + which icon. Animates whenever [bumpKey] changes,
/// so chained double-taps re-trigger the animation without needing to drop
/// the widget out of the tree.
class DoubleTapRipple extends StatefulWidget {
  const DoubleTapRipple({super.key, required this.state});

  final RippleState state;

  @override
  State<DoubleTapRipple> createState() => _DoubleTapRippleState();
}

class _DoubleTapRippleState extends State<DoubleTapRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: OttPlayerTokens.rippleDuration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.state.visible) _anim.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant DoubleTapRipple oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.bumpKey != oldWidget.state.bumpKey) {
      _anim.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (!state.visible) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final t = _anim.value;
          if (t == 0) return const SizedBox.shrink();
          final fade = (1 - t).clamp(0.0, 1.0);
          final scale = 0.6 + 0.5 * Curves.easeOut.transform(t);
          return _RipplePainterScope(
            forward: state.forward,
            opacity: fade,
            scale: scale,
            child: _SkipBadge(
              forward: state.forward,
              seconds: state.skipSeconds,
              opacity: fade,
            ),
          );
        },
      ),
    );
  }
}

class _RipplePainterScope extends StatelessWidget {
  const _RipplePainterScope({
    required this.forward,
    required this.opacity,
    required this.scale,
    required this.child,
  });

  final bool forward;
  final double opacity;
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: forward ? null : 0,
          right: forward ? 0 : null,
          top: 0,
          bottom: 0,
          width: MediaQuery.sizeOf(context).width / 2,
          child: Transform.scale(
            scale: scale,
            alignment: forward
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: forward
                      ? const Alignment(1, 0)
                      : const Alignment(-1, 0),
                  radius: 0.85,
                  colors: [
                    Colors.white.withValues(alpha: 0.25 * opacity),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: forward ? null : 0,
          right: forward ? 0 : null,
          top: 0,
          bottom: 0,
          width: MediaQuery.sizeOf(context).width / 2,
          child: Center(child: child),
        ),
      ],
    );
  }
}

class _SkipBadge extends StatelessWidget {
  const _SkipBadge({
    required this.forward,
    required this.seconds,
    required this.opacity,
  });

  final bool forward;
  final int seconds;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              forward
                  ? Icons.forward_10_rounded
                  : Icons.replay_10_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              '${forward ? '+' : '−'}$seconds s',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
