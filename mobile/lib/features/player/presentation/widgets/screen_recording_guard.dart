import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

/// Wraps a child and blocks screen capture while mounted.
///
/// Android: enables `FLAG_SECURE` — the OS renders a black frame in
/// screenshots and screen recordings. Re-applied on every `resumed` lifecycle
/// because some launchers / record-screen flows clear the flag when the app
/// is backgrounded.
///
/// iOS: there is no API to block recording outright, so we listen for
/// `UIScreen.isCaptured` and overlay an opaque "Recording is not allowed"
/// surface while recording is active. Screenshots get the system blur
/// overlay (`protectDataLeakageWithBlur`).
class ScreenRecordingGuard extends StatefulWidget {
  const ScreenRecordingGuard({super.key, required this.child});

  final Widget child;

  @override
  State<ScreenRecordingGuard> createState() => _ScreenRecordingGuardState();
}

class _ScreenRecordingGuardState extends State<ScreenRecordingGuard>
    with WidgetsBindingObserver {
  bool _isRecording = false;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableProtection();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Re-apply on every resume — Android sometimes clears FLAG_SECURE when
    // the activity goes to background and back, leaving a window where
    // recording could capture frames if we didn't reset it.
    if (state == AppLifecycleState.resumed) {
      _enableProtection();
    }
  }

  Future<void> _enableProtection() async {
    try {
      if (Platform.isAndroid) {
        await ScreenProtector.protectDataLeakageOn();
        _enabled = true;
        return;
      }
      if (Platform.isIOS) {
        await ScreenProtector.protectDataLeakageWithBlur();
        ScreenProtector.addListener(null, (isCaptured) {
          if (!mounted) return;
          setState(() => _isRecording = isCaptured);
        });
        _enabled = true;
      }
    } catch (_) {
      // Plugin missing or unsupported platform — fail open so playback
      // continues (per platform default), but don't crash the player.
    }
  }

  Future<void> _disableProtection() async {
    if (!_enabled) return;
    _enabled = false;
    try {
      if (Platform.isIOS) {
        ScreenProtector.removeListener();
        await ScreenProtector.protectDataLeakageWithBlurOff();
      }
      await ScreenProtector.protectDataLeakageOff();
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disableProtection());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) {
      return const ColoredBox(
        color: Colors.black,
        child: SizedBox.expand(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videocam_off_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Screen recording is not allowed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Stop recording to continue watching.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
