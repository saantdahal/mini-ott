import 'package:flutter/material.dart';

import 'screen_recording_guard.dart';

class PlayerScaffold extends StatelessWidget {
  const PlayerScaffold({
    super.key,
    required this.title,
    required this.child,
    this.immersive = false,
  });

  final String title;
  final Widget child;

  /// When true, removes the app bar and uses a black background so the child
  /// (typically the video surface) can extend edge-to-edge.
  final bool immersive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (immersive) {
      return ScreenRecordingGuard(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: child,
        ),
      );
    }
    return ScreenRecordingGuard(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: child,
      ),
    );
  }
}
