import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

import '../../../content_details/domain/entities/title_detail.dart';
import 'ott/ott_player_view.dart';

/// Backwards-compatible wrapper kept so existing callers that import
/// `player_view.dart` and instantiate `PlayerView(...)` continue to compile.
/// Forwards every parameter to the new [OttPlayerView]; new code should use
/// `OttPlayerView` directly.
class PlayerView extends StatelessWidget {
  const PlayerView({
    super.key,
    required this.controller,
    required this.title,
    this.subtitle,
    this.progressKey,
    this.playlist,
    this.currentIndex = 0,
    this.onPickEpisode,
    this.introStart,
    this.introEnd,
  });

  final BetterPlayerController controller;
  final String title;
  final String? subtitle;
  final String? progressKey;
  final List<TitleEpisode>? playlist;
  final int currentIndex;
  final ValueChanged<int>? onPickEpisode;
  final Duration? introStart;
  final Duration? introEnd;

  @override
  Widget build(BuildContext context) {
    return OttPlayerView(
      controller: controller,
      title: title,
      subtitle: subtitle,
      progressKey: progressKey,
      playlist: playlist,
      currentIndex: currentIndex,
      onPickEpisode: onPickEpisode,
      introStart: introStart,
      introEnd: introEnd,
    );
  }
}
