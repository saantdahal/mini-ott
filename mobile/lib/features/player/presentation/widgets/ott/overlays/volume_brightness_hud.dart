import 'package:flutter/material.dart';

import '../gestures/composite_gesture_layer.dart' show VerticalSide;
import '../theme/ott_player_tokens.dart';

/// Compact vertical bar that appears on the side being dragged. Identical
/// across volume / brightness — only the icon and side change.
class VolumeBrightnessHud extends StatelessWidget {
  const VolumeBrightnessHud({
    super.key,
    required this.side,
    required this.value,
  });

  final VerticalSide side;
  final double value;

  IconData get _icon {
    if (side == VerticalSide.right) {
      // brightness
      return value < 0.05
          ? Icons.brightness_low_rounded
          : value < 0.5
              ? Icons.brightness_medium_rounded
              : Icons.brightness_high_rounded;
    }
    // volume
    return value < 0.01
        ? Icons.volume_off_rounded
        : value < 0.5
            ? Icons.volume_down_rounded
            : Icons.volume_up_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: side == VerticalSide.left
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: 46,
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  '${(value * 100).round()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 6,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(
                          OttPlayerTokens.accentSoft,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Icon(_icon, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
