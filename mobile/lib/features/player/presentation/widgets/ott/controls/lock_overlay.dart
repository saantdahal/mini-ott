import 'dart:async';

import 'package:flutter/material.dart';

/// Full-screen scrim shown while the player is locked. Swallows every gesture
/// and reveals only an unlock affordance that fades after 3 s of inactivity.
/// Tap / drag anywhere re-shows the unlock button.
class LockOverlay extends StatefulWidget {
  const LockOverlay({super.key, required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  State<LockOverlay> createState() => _LockOverlayState();
}

class _LockOverlayState extends State<LockOverlay> {
  bool _showButton = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showButton = false);
    });
  }

  void _reveal() {
    setState(() => _showButton = true);
    _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _reveal,
      onDoubleTap: _reveal,
      onLongPress: _reveal,
      onVerticalDragStart: (_) => _reveal(),
      onHorizontalDragStart: (_) => _reveal(),
      child: SafeArea(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: IgnorePointer(
              ignoring: !_showButton,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showButton ? 1 : 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onUnlock,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.62),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_open_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
