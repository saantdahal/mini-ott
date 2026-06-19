import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '_sheet_chrome.dart';

const _speeds = <double>[0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

class PlaybackSpeedSheet extends StatelessWidget {
  const PlaybackSpeedSheet({
    super.key,
    required this.controller,
    required this.current,
    required this.onChanged,
  });

  final BetterPlayerController controller;
  final double current;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return PlayerSheetScaffold(
      title: 'Playback speed',
      subtitle: 'Currently $current×',
      child: ListView(
        shrinkWrap: true,
        children: _speeds
            .map(
              (s) => SheetOptionTile(
                label: s == 1.0 ? 'Normal (1×)' : '$s×',
                selected: (s - current).abs() < 0.01,
                onTap: () {
                  try {
                    controller.setSpeed(s);
                  } catch (_) {}
                  onChanged(s);
                  Navigator.of(context).maybePop();
                },
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
