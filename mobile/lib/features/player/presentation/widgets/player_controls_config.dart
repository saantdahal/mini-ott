import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

/// BetterPlayer's built-in control surface is fully **disabled** here — every
/// piece of chrome (top bar, progress, overflow menu, mute, PiP, fullscreen,
/// skip buttons) is reimplemented in Flutter under `presentation/widgets/ott/`.
///
/// We keep BetterPlayer purely as the playback engine; nothing it draws above
/// the video texture should remain visible. The custom [OttPlayerView] also
/// calls `controller.setControlsEnabled(false)` after init as a belt-and-braces
/// guarantee for builds where some flags above are still honoured.
BetterPlayerControlsConfiguration buildPlayerControlsConfiguration() {
  return const BetterPlayerControlsConfiguration(
    controlBarColor: Colors.transparent,
    backgroundColor: Colors.black,
    enableSkips: false,
    enableMute: false,
    enableFullscreen: false,
    enablePlayPause: false,
    enableProgressBar: false,
    enableProgressBarDrag: false,
    enableProgressText: false,
    enableOverflowMenu: false,
    enablePlaybackSpeed: false,
    enableQualities: false,
    enablePip: false,
    enableSubtitles: false,
    enableAudioTracks: false,
    enableRetry: true,
    controlBarHeight: 0,
  );
}
