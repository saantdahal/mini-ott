import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '../theme/ott_player_tokens.dart';

/// Modern, scrubbable seek bar painted from scratch:
///   • thin track     (background)
///   • buffered fill  (translucent white)
///   • played fill    (gradient)
///   • thumb          (filled circle, shadow)
///
/// Listens to the `VideoPlayerController` directly so the rest of the chrome
/// doesn't rebuild on every position tick. While the user is dragging, the
/// bar paints a synthetic position based on drag offset — only seeking the
/// actual player on drag end (cheap + smooth).
class ModernProgressBar extends StatefulWidget {
  const ModernProgressBar({
    super.key,
    required this.controller,
    this.onScrubStart,
    this.onScrubEnd,
    this.height = 28,
    this.scrubFraction,
  });

  final BetterPlayerController controller;
  final VoidCallback? onScrubStart;
  final VoidCallback? onScrubEnd;
  final double height;

  /// Externally-owned scrub-fraction notifier. When supplied, the bar writes
  /// drag updates here so siblings (e.g. the time label) can preview the
  /// seek target. Falls back to internal state when null.
  final ValueNotifier<double?>? scrubFraction;

  @override
  State<ModernProgressBar> createState() => _ModernProgressBarState();
}

class _ModernProgressBarState extends State<ModernProgressBar> {
  bool _scrubbing = false;
  late final ValueNotifier<double?> _scrubFraction;
  bool _ownsScrubFraction = false;

  @override
  void initState() {
    super.initState();
    final external = widget.scrubFraction;
    if (external != null) {
      _scrubFraction = external;
    } else {
      _scrubFraction = ValueNotifier<double?>(null);
      _ownsScrubFraction = true;
    }
  }

  @override
  void dispose() {
    if (_ownsScrubFraction) _scrubFraction.dispose();
    super.dispose();
  }

  void _seekToFraction(double fraction) {
    final inner = widget.controller.videoPlayerController;
    if (inner == null) return;
    final total = inner.value.duration;
    if (total == null || total.inMilliseconds == 0) return;
    final target = Duration(
      milliseconds: (fraction.clamp(0.0, 1.0) * total.inMilliseconds).round(),
    );
    widget.controller.seekTo(target);
  }

  @override
  Widget build(BuildContext context) {
    final inner = widget.controller.videoPlayerController;
    if (inner == null) {
      return SizedBox(height: widget.height);
    }
    return SizedBox(
      height: widget.height,
      child: ListenableBuilder(
        listenable: Listenable.merge([inner, _scrubFraction]),
        builder: (context, _) {
          final value = inner.value;
          final total = value.duration ?? Duration.zero;
          final pos = value.position;
          final played = total.inMilliseconds == 0
              ? 0.0
              : (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
          double buffered = 0;
          if (total.inMilliseconds > 0 && value.buffered.isNotEmpty) {
            final last = value.buffered.last.end;
            buffered = (last.inMilliseconds / total.inMilliseconds)
                .clamp(0.0, 1.0);
          }
          final displayPlayed = _scrubFraction.value ?? played;
          return LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (details) {
                  _scrubbing = true;
                  _scrubFraction.value = (details.localPosition.dx /
                          constraints.maxWidth)
                      .clamp(0.0, 1.0);
                  setState(() {});
                  widget.onScrubStart?.call();
                },
                onHorizontalDragUpdate: (details) {
                  if (!_scrubbing) return;
                  _scrubFraction.value = (details.localPosition.dx /
                          constraints.maxWidth)
                      .clamp(0.0, 1.0);
                },
                onHorizontalDragEnd: (_) {
                  if (!_scrubbing) return;
                  final f = _scrubFraction.value;
                  if (f != null) _seekToFraction(f);
                  _scrubbing = false;
                  _scrubFraction.value = null;
                  setState(() {});
                  widget.onScrubEnd?.call();
                },
                onTapDown: (details) {
                  final f = (details.localPosition.dx /
                          constraints.maxWidth)
                      .clamp(0.0, 1.0);
                  _seekToFraction(f);
                },
                child: CustomPaint(
                  size: Size(constraints.maxWidth, widget.height),
                  painter: _ProgressPainter(
                    played: displayPlayed,
                    buffered: buffered,
                    expanded: _scrubbing,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter({
    required this.played,
    required this.buffered,
    required this.expanded,
  });

  final double played;
  final double buffered;
  final bool expanded;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final trackHeight = expanded ? 5.0 : 3.0;
    final trackRect = RRect.fromLTRBR(
      0,
      cy - trackHeight / 2,
      size.width,
      cy + trackHeight / 2,
      Radius.circular(trackHeight / 2),
    );

    // Background track
    canvas.drawRRect(
      trackRect,
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    // Buffered
    if (buffered > 0) {
      final bufferedRect = RRect.fromLTRBR(
        0,
        cy - trackHeight / 2,
        size.width * buffered,
        cy + trackHeight / 2,
        Radius.circular(trackHeight / 2),
      );
      canvas.drawRRect(
        bufferedRect,
        Paint()..color = Colors.white.withValues(alpha: 0.32),
      );
    }

    // Played (gradient)
    if (played > 0) {
      final playedWidth = size.width * played;
      final playedRect = RRect.fromLTRBR(
        0,
        cy - trackHeight / 2,
        playedWidth,
        cy + trackHeight / 2,
        Radius.circular(trackHeight / 2),
      );
      final paint = Paint()
        ..shader = OttPlayerTokens.progressFill.createShader(
          Rect.fromLTWH(0, 0, playedWidth.clamp(1.0, size.width), size.height),
        );
      canvas.drawRRect(playedRect, paint);
    }

    // Thumb
    final thumbX = (size.width * played).clamp(0.0, size.width);
    final thumbR = expanded ? 9.0 : 6.5;
    canvas.drawCircle(
      Offset(thumbX, cy),
      thumbR + 2,
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      Offset(thumbX, cy),
      thumbR,
      Paint()..color = OttPlayerTokens.accentSoft,
    );
    canvas.drawCircle(
      Offset(thumbX, cy),
      thumbR - 2.5,
      Paint()..color = OttPlayerTokens.accent,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter old) =>
      old.played != played ||
      old.buffered != buffered ||
      old.expanded != expanded;
}
