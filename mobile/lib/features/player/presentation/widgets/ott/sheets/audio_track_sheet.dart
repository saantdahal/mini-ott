import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '_sheet_chrome.dart';

/// Lists audio tracks pulled from the HLS manifest. With the current backend
/// only one track is ever served, so this sheet typically reports "Default".
/// [onPicked] reports the human-readable label of the chosen track so the
/// bottom-bar label can mirror it.
class AudioTrackSheet extends StatelessWidget {
  const AudioTrackSheet({
    super.key,
    required this.controller,
    required this.onPicked,
  });

  final BetterPlayerController controller;
  final ValueChanged<String> onPicked;

  String _labelFor(BetterPlayerAsmsAudioTrack t, int index) {
    final lang = t.language;
    final label = t.label;
    if (label != null && label.isNotEmpty) return label;
    if (lang != null && lang.isNotEmpty) return lang.toUpperCase();
    return 'Audio ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final tracks = controller.betterPlayerAsmsAudioTracks ?? const [];
    final current = controller.betterPlayerAsmsAudioTrack;
    return PlayerSheetScaffold(
      title: 'Audio',
      subtitle: tracks.length <= 1
          ? 'Only one audio track is available.'
          : 'Pick the audio track to play.',
      child: ListView(
        shrinkWrap: true,
        children: [
          if (tracks.isEmpty)
            const SheetOptionTile(
              label: 'Default',
              selected: true,
              onTap: _noop,
            )
          else
            ...tracks.asMap().entries.map(
                  (e) => SheetOptionTile(
                    label: _labelFor(e.value, e.key),
                    selected: identical(current, e.value),
                    onTap: () {
                      try {
                        controller.setAudioTrack(e.value);
                      } catch (_) {}
                      onPicked(_labelFor(e.value, e.key));
                      Navigator.of(context).maybePop();
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

void _noop() {}
