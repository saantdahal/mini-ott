import 'package:flutter/material.dart';

import '../theme/ott_player_tokens.dart';

/// Floating preview shown while the user horizontally drags to seek. Renders
/// the target time and the signed delta, plus a thin progress ribbon.
class SeekPreviewHud extends StatelessWidget {
  const SeekPreviewHud({
    super.key,
    required this.targetPosition,
    required this.delta,
    required this.totalDuration,
  });

  final Duration targetPosition;
  final Duration delta;
  final Duration totalDuration;

  String _fmt(Duration d) {
    final hours = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isForward = delta >= Duration.zero;
    final fraction = totalDuration.inMilliseconds == 0
        ? 0.0
        : (targetPosition.inMilliseconds / totalDuration.inMilliseconds)
            .clamp(0.0, 1.0);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isForward
                      ? Icons.fast_forward_rounded
                      : Icons.fast_rewind_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  _fmt(targetPosition),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '/ ${_fmt(totalDuration)}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 220,
              height: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: fraction,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(
                    OttPlayerTokens.accentSoft,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${isForward ? '+' : '−'}${_fmt(Duration(
                milliseconds: delta.inMilliseconds.abs(),
              ))}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
