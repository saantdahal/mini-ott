import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Position / duration text driven directly by `BetterPlayer`'s underlying
/// `VideoPlayerController`. Uses `ValueListenableBuilder` so only this widget
/// rebuilds when the playhead moves — the rest of the chrome stays still.
///
/// When [scrubFraction] is supplied and emits a non-null value, the label
/// previews the seek target instead of the actual playhead so users can see
/// where they're about to land while dragging the progress bar.
class TimeLabel extends StatelessWidget {
  const TimeLabel({
    super.key,
    required this.controller,
    this.style,
    this.separator = '/',
    this.scrubFraction,
  });

  final BetterPlayerController controller;
  final TextStyle? style;
  final String separator;
  final ValueListenable<double?>? scrubFraction;

  static String format(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final hours = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final inner = controller.videoPlayerController;
    final base = style ??
        const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFeatures: [FontFeature.tabularFigures()],
        );
    if (inner == null) {
      return Text('00:00 $separator 00:00', style: base);
    }
    final scrub = scrubFraction;
    final listenable = scrub == null
        ? inner as Listenable
        : Listenable.merge([inner, scrub]);
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        final value = inner.value;
        final total = value.duration ?? Duration.zero;
        final f = scrub?.value;
        final pos = (f != null && total > Duration.zero)
            ? Duration(
                milliseconds:
                    (f.clamp(0.0, 1.0) * total.inMilliseconds).round(),
              )
            : value.position;
        return Text('${format(pos)} $separator ${format(total)}', style: base);
      },
    );
  }
}
