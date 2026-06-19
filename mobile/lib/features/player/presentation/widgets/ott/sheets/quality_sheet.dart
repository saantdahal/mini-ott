import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '_sheet_chrome.dart';

/// Lists every video variant exposed by the HLS adaptive manifest, plus an
/// "Auto" entry that hands selection back to the engine. Reads tracks from
/// `BetterPlayerController.betterPlayerAsmsTracks`; if the list is empty
/// (non-HLS source or single-bitrate MP4) the sheet shows just "Auto".
///
/// [onPicked] is invoked with the chosen track (null = auto) so the player
/// chrome can mirror the selection in its bottom-bar label.
class QualitySheet extends StatelessWidget {
  const QualitySheet({
    super.key,
    required this.controller,
    required this.onPicked,
  });

  final BetterPlayerController controller;
  final ValueChanged<BetterPlayerAsmsTrack?> onPicked;

  String _labelFor(BetterPlayerAsmsTrack t) {
    final h = t.height ?? 0;
    final w = t.width ?? 0;
    final br = t.bitrate ?? 0;
    final mbps = br > 0 ? (br / 1000000).toStringAsFixed(1) : null;
    if (h > 0) {
      final base = '${h}p';
      return mbps != null ? '$base · $mbps Mbps' : base;
    }
    if (w > 0 && br > 0) return '${w}w · ${(br / 1000).round()} kbps';
    return 'Variant';
  }

  @override
  Widget build(BuildContext context) {
    final tracks = controller.betterPlayerAsmsTracks;
    final selected = controller.betterPlayerAsmsTrack;
    return PlayerSheetScaffold(
      title: 'Video quality',
      subtitle:
          'Auto adapts to your network. Pick a level to lock the bitrate.',
      child: ListView(
        shrinkWrap: true,
        children: [
          SheetOptionTile(
            label: 'Auto',
            selected: selected == null,
            subtitle: 'Recommended',
            onTap: () {
              try {
                controller.setTrack(BetterPlayerAsmsTrack.defaultTrack());
              } catch (_) {}
              onPicked(null);
              Navigator.of(context).maybePop();
            },
          ),
          ...tracks.map(
            (t) => SheetOptionTile(
              label: _labelFor(t),
              selected: selected == t,
              onTap: () {
                try {
                  controller.setTrack(t);
                } catch (_) {}
                onPicked(t);
                Navigator.of(context).maybePop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
