import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';

enum TapZone { left, center, right }

enum DragMode { none, vertical, horizontal, scale }

enum VerticalSide { left, right }

class DragSeekUpdate {
  const DragSeekUpdate({
    required this.targetPosition,
    required this.delta,
    required this.fraction,
    required this.committing,
  });

  final Duration targetPosition;
  final Duration delta;
  final double fraction;
  final bool committing;
}

class VerticalLevelUpdate {
  const VerticalLevelUpdate({required this.side, required this.value});
  final VerticalSide side;
  final double value;
}

/// Single-`GestureDetector` layer that handles every player-area gesture in
/// one place: tap, double-tap (with side-zone detection), vertical drag
/// (volume / brightness), horizontal drag (scrub), and pinch (fit cycle).
///
/// Putting them in one detector matters: when two sibling detectors register
/// recognizers in the same gesture arena, the scale recognizer (single-finger
/// pan) often wins on quick taps and silently kills the double-tap recogniser.
/// One detector lets Flutter coordinate them internally.
class CompositeGestureLayer extends StatefulWidget {
  const CompositeGestureLayer({
    super.key,
    required this.controller,
    required this.locked,
    required this.totalDuration,
    required this.currentPosition,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLevelChanged,
    required this.onLevelEnded,
    required this.onSeekUpdate,
    required this.onScale,
  });

  final BetterPlayerController controller;
  final bool locked;
  final Duration totalDuration;
  final ValueGetter<Duration> currentPosition;
  final ValueChanged<TapZone> onTap;
  final ValueChanged<TapZone> onDoubleTap;
  final ValueChanged<VerticalLevelUpdate> onLevelChanged;
  final VoidCallback onLevelEnded;
  final ValueChanged<DragSeekUpdate> onSeekUpdate;
  final ValueChanged<double> onScale;

  @override
  State<CompositeGestureLayer> createState() => _CompositeGestureLayerState();
}

class _CompositeGestureLayerState extends State<CompositeGestureLayer> {
  static const double _slop = 14;
  static const double _maxSeekFraction = 0.5;

  DragMode _mode = DragMode.none;
  VerticalSide _side = VerticalSide.left;
  double _currentLevel = 0;
  double _accumDx = 0;
  double _accumDy = 0;
  Duration _seekAnchor = Duration.zero;
  Timer? _hudReset;

  @override
  void initState() {
    super.initState();
    FlutterVolumeController.updateShowSystemUI(false).catchError((_) {});
  }

  @override
  void dispose() {
    _hudReset?.cancel();
    ScreenBrightness().resetApplicationScreenBrightness().catchError((_) {});
    super.dispose();
  }

  TapZone _zoneFor(Offset localPosition, double width) {
    final third = width / 3;
    if (localPosition.dx < third) return TapZone.left;
    if (localPosition.dx > width - third) return TapZone.right;
    return TapZone.center;
  }

  Future<double> _readCurrentLevel(VerticalSide side) async {
    try {
      if (side == VerticalSide.left) {
        final v = await FlutterVolumeController.getVolume();
        return (v ?? 0).clamp(0.0, 1.0);
      } else {
        final v = await ScreenBrightness().application;
        return v.clamp(0.0, 1.0);
      }
    } catch (_) {
      return 0;
    }
  }

  Future<void> _applyLevel(VerticalSide side, double value) async {
    try {
      if (side == VerticalSide.left) {
        await FlutterVolumeController.setVolume(value);
      } else {
        await ScreenBrightness().setApplicationScreenBrightness(value);
      }
    } catch (_) {}
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (widget.locked) return;
    _mode = DragMode.none;
    _accumDx = 0;
    _accumDy = 0;
    if (details.pointerCount == 1) {
      _seekAnchor = widget.currentPosition();
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (widget.locked) return;

    if (details.pointerCount >= 2 && details.scale != 1.0) {
      _mode = DragMode.scale;
      widget.onScale(details.scale);
      return;
    }

    if (_mode == DragMode.none) {
      _accumDx += details.focalPointDelta.dx;
      _accumDy += details.focalPointDelta.dy;
      if (_accumDx.abs() < _slop && _accumDy.abs() < _slop) return;
      if (_accumDy.abs() > _accumDx.abs()) {
        _mode = DragMode.vertical;
        final size = MediaQuery.sizeOf(context);
        _side = (details.focalPoint.dx < size.width / 2)
            ? VerticalSide.left
            : VerticalSide.right;
        _readCurrentLevel(_side).then((value) {
          if (!mounted || _mode != DragMode.vertical) return;
          _currentLevel = value;
          widget.onLevelChanged(
            VerticalLevelUpdate(side: _side, value: _currentLevel),
          );
        });
      } else {
        _mode = DragMode.horizontal;
        _seekAnchor = widget.currentPosition();
      }
    }

    if (_mode == DragMode.vertical) {
      final size = MediaQuery.sizeOf(context);
      final delta = -details.focalPointDelta.dy / (size.height * 0.6);
      final next = (_currentLevel + delta).clamp(0.0, 1.0);
      if (next == _currentLevel) return;
      _currentLevel = next;
      widget.onLevelChanged(
        VerticalLevelUpdate(side: _side, value: _currentLevel),
      );
      _applyLevel(_side, _currentLevel);
    } else if (_mode == DragMode.horizontal) {
      final width = MediaQuery.sizeOf(context).width;
      final fraction = (details.focalPointDelta.dx / width) * _maxSeekFraction;
      final totalMs = widget.totalDuration.inMilliseconds;
      if (totalMs <= 0) return;
      final newPos = _seekAnchor +
          Duration(milliseconds: (fraction * totalMs).round());
      final clamped = Duration(
        milliseconds: newPos.inMilliseconds.clamp(0, totalMs),
      );
      _seekAnchor = clamped;
      widget.onSeekUpdate(
        DragSeekUpdate(
          targetPosition: clamped,
          delta: clamped - widget.currentPosition(),
          fraction: clamped.inMilliseconds / totalMs,
          committing: false,
        ),
      );
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (widget.locked) return;
    if (_mode == DragMode.vertical) {
      _hudReset?.cancel();
      widget.onLevelEnded();
    } else if (_mode == DragMode.horizontal) {
      try {
        widget.controller.seekTo(_seekAnchor);
      } catch (_) {}
      widget.onSeekUpdate(
        DragSeekUpdate(
          targetPosition: _seekAnchor,
          delta: Duration.zero,
          fraction: widget.totalDuration.inMilliseconds == 0
              ? 0
              : _seekAnchor.inMilliseconds /
                  widget.totalDuration.inMilliseconds,
          committing: true,
        ),
      );
    }
    _mode = DragMode.none;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locked) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          // Tap recognizer
          onTapUp: (details) {
            // Don't fire tap if we just finished a drag — `_mode` is reset to
            // none by `_onScaleEnd` before this fires only on clean taps.
            if (_mode != DragMode.none) {
              _mode = DragMode.none;
              return;
            }
            widget.onTap(_zoneFor(details.localPosition, constraints.maxWidth));
          },
          // Double-tap recognizer — `onDoubleTap` (even empty) is required for
          // `onDoubleTapDown` to fire; `onDoubleTapDown` carries the position.
          onDoubleTapDown: (details) {
            HapticFeedback.lightImpact();
            widget.onDoubleTap(
              _zoneFor(details.localPosition, constraints.maxWidth),
            );
          },
          onDoubleTap: () {},
          // Scale (drag + pinch) recognizer
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: const SizedBox.expand(),
        );
      },
    );
  }
}
