import 'dart:async';

import 'package:flutter/foundation.dart';

import '../widgets/ott/theme/ott_player_tokens.dart';

/// Owns the chrome-visibility flag and the inactivity timer. Exposed as a
/// [ValueNotifier] so widgets can rebuild only the parts that depend on
/// visibility, instead of `setState`-ing the whole player.
class AutoHideController extends ValueNotifier<bool> {
  AutoHideController({Duration? delay})
      : _delay = delay ?? OttPlayerTokens.autoHideDelay,
        super(true) {
    _scheduleHide();
  }

  final Duration _delay;
  Timer? _timer;
  bool _suspended = false;

  /// User interaction occurred — show chrome and reset the auto-hide timer.
  void poke() {
    if (!value) value = true;
    _scheduleHide();
  }

  /// Show chrome and keep it visible until [resume] is called. Used when a
  /// modal sheet is open or the player is paused.
  void suspend() {
    _suspended = true;
    _timer?.cancel();
    if (!value) value = true;
  }

  void resume() {
    _suspended = false;
    _scheduleHide();
  }

  void hide() {
    if (_suspended) return;
    if (value) value = false;
  }

  void show() {
    if (!value) value = true;
  }

  void _scheduleHide() {
    _timer?.cancel();
    if (_suspended) return;
    _timer = Timer(_delay, () {
      if (_suspended) return;
      value = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
