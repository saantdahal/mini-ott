import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../content_details/domain/entities/title_detail.dart';
import '../../controllers/auto_hide_controller.dart';
import '../../providers/playback_settings_provider.dart';
import '../../providers/player_ui_controller.dart';
import '../../providers/watch_progress_notifier.dart';
import 'animations/fade_overlay.dart';
import 'controls/bottom_controls_bar.dart';
import 'controls/center_controls.dart';
import 'controls/lock_overlay.dart';
import 'controls/top_controls_bar.dart';
import 'gestures/composite_gesture_layer.dart';
import 'overlays/buffering_indicator.dart';
import 'overlays/double_tap_ripple.dart';
import 'overlays/seek_preview_hud.dart';
import 'overlays/skip_intro_button.dart';
import 'overlays/volume_brightness_hud.dart';
import 'sheets/_sheet_chrome.dart';
import 'sheets/audio_track_sheet.dart';
import 'sheets/episode_list_sheet.dart';
import 'sheets/playback_speed_sheet.dart';
import 'sheets/quality_sheet.dart';
import 'sheets/settings_sheet.dart';
import 'sheets/subtitle_sheet.dart';
import 'theme/ott_player_tokens.dart';

/// Root composition for the OTT custom player UI. Owns:
///   • the auto-hide controller (chrome visibility)
///   • the gesture HUD state (volume / brightness / seek preview)
///   • the double-tap ripple state (chained skip)
///   • watch-progress save loop and resume-on-init
///
/// All UI tweakables (lock, fit, buffering, speed) live in
/// [PlayerUiController] which is provider-scoped; this widget only owns the
/// transient overlay state that doesn't need to survive a rebuild.
class OttPlayerView extends ConsumerStatefulWidget {
  const OttPlayerView({
    super.key,
    required this.controller,
    required this.title,
    this.playerKey,
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

  /// `GlobalKey` attached to the underlying `BetterPlayer` widget. Required
  /// when the parent wants to invoke Picture-in-Picture, since the engine
  /// needs to locate the live render surface. Optional otherwise.
  final GlobalKey? playerKey;

  /// Stable id used as the watch-progress key. When null, progress is not
  /// persisted (anonymous-stream mode).
  final String? progressKey;

  /// Optional season episode list for queue-aware features.
  final List<TitleEpisode>? playlist;
  final int currentIndex;
  final ValueChanged<int>? onPickEpisode;

  /// Intro markers; both null = button never appears.
  final Duration? introStart;
  final Duration? introEnd;

  @override
  ConsumerState<OttPlayerView> createState() => _OttPlayerViewState();
}

class _OttPlayerViewState extends ConsumerState<OttPlayerView> {
  late final AutoHideController _autoHide;

  // Overlay HUD state — kept as plain fields + setState so listeners outside
  // the overlays never rebuild.
  VerticalLevelUpdate? _levelHud;
  Timer? _levelHudTimer;
  DragSeekUpdate? _seekHud;
  RippleState _ripple = RippleState.hidden;
  Timer? _rippleClearTimer;
  int _rippleAccumulator = 0;
  bool _scrubbing = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _saveTimer;
  bool _resumeAttempted = false;

  @override
  void initState() {
    super.initState();
    _autoHide = AutoHideController();
    widget.controller.addEventsListener(_onEvent);
    final inner = widget.controller.videoPlayerController;
    inner?.addListener(_onPositionTick);
    try {
      widget.controller.setControlsEnabled(false);
    } catch (_) {}
    _saveTimer = Timer.periodic(
      OttPlayerTokens.progressSaveInterval,
      (_) => _persistProgress(),
    );
  }

  @override
  void didUpdateWidget(covariant OttPlayerView old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeEventsListener(_onEvent);
      old.controller.videoPlayerController?.removeListener(_onPositionTick);
      widget.controller.addEventsListener(_onEvent);
      widget.controller.videoPlayerController?.addListener(_onPositionTick);
      try {
        widget.controller.setControlsEnabled(false);
      } catch (_) {}
      _resumeAttempted = false;
      // Reset per-source labels so they don't bleed across episodes.
      _safelyMutate(() {
        ref
            .read(playerUiControllerProvider.notifier)
            .setQualityLabel('Auto');
        ref.read(playerUiControllerProvider.notifier).setSubtitleLabel('Off');
        ref.read(playerUiControllerProvider.notifier).setAudioLabel('Default');
      });
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _levelHudTimer?.cancel();
    _rippleClearTimer?.cancel();
    widget.controller.removeEventsListener(_onEvent);
    widget.controller.videoPlayerController?.removeListener(_onPositionTick);
    _persistProgress();
    _autoHide.dispose();
    // Belt-and-braces: hard-reset to portrait + visible system bars on the
    // way out. The hosting screen also does this in its own dispose, but
    // covering both ends means a stale landscape lock can never leak out of
    // the player into another screen, even if the screen rebuilds in a way
    // that swaps OttPlayerView without fully tearing the route down.
    unawaited(SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]));
    unawaited(SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    ));
    super.dispose();
  }

  // ── Player events ──────────────────────────────────────────────────────

  /// BetterPlayer can fire events synchronously from inside a build phase
  /// (e.g. `bufferingStart` while `BetterPlayer.initState` is running). Any
  /// state mutation we perform must be deferred so it lands in the next
  /// frame, otherwise Flutter throws "setState during build" or marks an
  /// unrelated ancestor dirty.
  void _safelyMutate(VoidCallback action) {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      action();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) action();
      });
    }
  }

  void _onEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        _safelyMutate(_maybeResume);
      case BetterPlayerEventType.bufferingStart:
        _safelyMutate(
          () => ref
              .read(playerUiControllerProvider.notifier)
              .setBuffering(true),
        );
      case BetterPlayerEventType.bufferingEnd:
        _safelyMutate(
          () => ref
              .read(playerUiControllerProvider.notifier)
              .setBuffering(false),
        );
      case BetterPlayerEventType.finished:
        _safelyMutate(_onPlaybackFinished);
      default:
        break;
    }
  }

  void _onPositionTick() {
    final inner = widget.controller.videoPlayerController;
    if (inner == null) return;
    final v = inner.value;
    final newPos = v.position;
    final newDur = v.duration ?? Duration.zero;
    if (newPos != _position) _position = newPos;
    if (newDur != _duration) _duration = newDur;
  }

  Future<void> _maybeResume() async {
    if (_resumeAttempted) return;
    _resumeAttempted = true;
    final key = widget.progressKey;
    if (key == null) return;
    final stored = await ref.read(watchProgressControllerProvider).read(key);
    if (stored == null || !stored.isResumable) return;
    if (!mounted) return;
    try {
      widget.controller.seekTo(stored.position);
    } catch (_) {}
  }

  Future<void> _persistProgress() async {
    final key = widget.progressKey;
    if (key == null) return;
    if (_position <= Duration.zero) return;
    if (_duration <= Duration.zero) return;
    await ref.read(watchProgressControllerProvider).save(
          key: key,
          position: _position,
          duration: _duration,
        );
  }

  void _onPlaybackFinished() {
    final key = widget.progressKey;
    if (key != null) {
      ref.read(watchProgressControllerProvider).clear(key);
    }
    final pl = widget.playlist;
    final next = widget.currentIndex + 1;
    if (pl == null || next >= pl.length) return;
    final autoPlay = ref.read(playbackSettingsProvider).autoPlayNextEpisode;
    if (!autoPlay) return;
    widget.onPickEpisode?.call(next);
  }

  // ── Tap / double-tap ───────────────────────────────────────────────────

  void _onTap(TapZone zone) {
    final ui = ref.read(playerUiControllerProvider);
    if (ui.locked) return;
    if (_autoHide.value) {
      _autoHide.hide();
    } else {
      _autoHide.show();
      _autoHide.poke();
    }
  }

  void _onDoubleTap(TapZone zone) {
    if (zone == TapZone.center) {
      _togglePlay();
      return;
    }
    final forward = zone == TapZone.right;
    _bumpRipple(forward);
    final inner = widget.controller.videoPlayerController;
    if (inner == null) return;
    final current = inner.value.position;
    final total = inner.value.duration ?? Duration.zero;
    final delta = Duration(
      seconds: forward
          ? OttPlayerTokens.doubleTapSeekStepSeconds
          : -OttPlayerTokens.doubleTapSeekStepSeconds,
    );
    var next = current + delta;
    if (next < Duration.zero) next = Duration.zero;
    if (total > Duration.zero && next > total) next = total;
    try {
      widget.controller.seekTo(next);
    } catch (_) {}
  }

  void _bumpRipple(bool forward) {
    _rippleClearTimer?.cancel();
    final sameDir = _ripple.visible && _ripple.forward == forward;
    _rippleAccumulator =
        sameDir ? _rippleAccumulator + OttPlayerTokens.doubleTapSeekStepSeconds
            : OttPlayerTokens.doubleTapSeekStepSeconds;
    setState(() {
      _ripple = RippleState(
        visible: true,
        forward: forward,
        skipSeconds: _rippleAccumulator,
        bumpKey: _ripple.bumpKey + 1,
      );
    });
    _rippleClearTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _ripple = RippleState.hidden);
      _rippleAccumulator = 0;
    });
  }

  void _togglePlay() {
    final inner = widget.controller.videoPlayerController;
    if (inner == null) return;
    if (inner.value.isPlaying) {
      widget.controller.pause();
      _autoHide.suspend();
    } else {
      widget.controller.play();
      _autoHide.resume();
    }
  }

  // ── Gesture HUD wiring ─────────────────────────────────────────────────

  void _onLevelChanged(VerticalLevelUpdate update) {
    _levelHudTimer?.cancel();
    setState(() => _levelHud = update);
  }

  void _onLevelEnded() {
    _levelHudTimer?.cancel();
    _levelHudTimer = Timer(OttPlayerTokens.hudDismissDelay, () {
      if (!mounted) return;
      setState(() => _levelHud = null);
    });
  }

  void _onSeekHud(DragSeekUpdate update) {
    setState(() => _seekHud = update.committing ? null : update);
  }

  void _onScale(double scale) {
    final ui = ref.read(playerUiControllerProvider.notifier);
    final state = ref.read(playerUiControllerProvider);
    if (scale > 1.05 && state.fit != BoxFit.cover) {
      ui.setFitIndex(PlayerUiState.fits.indexOf(BoxFit.cover));
      try {
        widget.controller.setOverriddenFit(BoxFit.cover);
      } catch (_) {}
    } else if (scale < 0.95 && state.fit != BoxFit.contain) {
      ui.setFitIndex(PlayerUiState.fits.indexOf(BoxFit.contain));
      try {
        widget.controller.setOverriddenFit(BoxFit.contain);
      } catch (_) {}
    }
  }

  // ── Sheet handlers ─────────────────────────────────────────────────────

  /// Format a quality track for display in the bottom bar / settings sheet.
  String _qualityLabelFor(BetterPlayerAsmsTrack? t) {
    if (t == null) return 'Auto';
    final h = t.height ?? 0;
    if (h > 0) return '${h}p';
    final br = t.bitrate ?? 0;
    if (br > 0) return '${(br / 1000).round()} kbps';
    return 'Auto';
  }

  Future<void> _openSettings() async {
    HapticFeedback.selectionClick();
    _autoHide.suspend();
    final ui = ref.read(playerUiControllerProvider);
    final pl = widget.playlist;
    final hasNextEpisode =
        pl != null && widget.currentIndex + 1 < pl.length;
    await PlayerSheetScaffold.show<void>(
      context: context,
      child: Consumer(
        builder: (context, sheetRef, _) {
          final autoPlayNext = hasNextEpisode
              ? sheetRef
                  .watch(playbackSettingsProvider)
                  .autoPlayNextEpisode
              : null;
          return SettingsSheet(
            speedLabel: ui.speedLabel,
            qualityLabel: ui.qualityLabel,
            subtitleLabel: ui.subtitleLabel,
            audioLabel: ui.audioLabel,
            onSpeed: _openSpeed,
            onQuality: _openQuality,
            onSubtitles: _openSubtitles,
            onAudio: _openAudio,
            autoPlayNext: autoPlayNext,
            onToggleAutoPlayNext: hasNextEpisode
                ? (v) => sheetRef
                    .read(playbackSettingsProvider.notifier)
                    .setAutoPlayNextEpisode(v)
                : null,
          );
        },
      ),
    );
    _autoHide.resume();
  }

  Future<void> _openSpeed() async {
    _autoHide.suspend();
    await PlayerSheetScaffold.show<void>(
      context: context,
      child: PlaybackSpeedSheet(
        controller: widget.controller,
        current: ref.read(playerUiControllerProvider).speed,
        onChanged: ref.read(playerUiControllerProvider.notifier).setSpeed,
      ),
    );
    _autoHide.resume();
  }

  Future<void> _openQuality() async {
    _autoHide.suspend();
    await PlayerSheetScaffold.show<void>(
      context: context,
      child: QualitySheet(
        controller: widget.controller,
        onPicked: (track) {
          ref
              .read(playerUiControllerProvider.notifier)
              .setQualityLabel(_qualityLabelFor(track));
        },
      ),
    );
    _autoHide.resume();
  }

  Future<void> _openSubtitles() async {
    _autoHide.suspend();
    await PlayerSheetScaffold.show<void>(
      context: context,
      child: SubtitleSheet(
        controller: widget.controller,
        onPicked: (label) => ref
            .read(playerUiControllerProvider.notifier)
            .setSubtitleLabel(label),
      ),
    );
    _autoHide.resume();
  }

  Future<void> _openAudio() async {
    _autoHide.suspend();
    await PlayerSheetScaffold.show<void>(
      context: context,
      child: AudioTrackSheet(
        controller: widget.controller,
        onPicked: (label) => ref
            .read(playerUiControllerProvider.notifier)
            .setAudioLabel(label),
      ),
    );
    _autoHide.resume();
  }

  Future<void> _openEpisodes() async {
    final pl = widget.playlist;
    if (pl == null || pl.isEmpty) return;
    _autoHide.suspend();
    await PlayerSheetScaffold.show<void>(
      context: context,
      child: EpisodeListSheet(
        episodes: pl,
        currentIndex: widget.currentIndex,
        onPick: (i) => widget.onPickEpisode?.call(i),
      ),
    );
    _autoHide.resume();
  }

  // ── Misc actions ───────────────────────────────────────────────────────

  void _toggleLock() {
    HapticFeedback.mediumImpact();
    ref.read(playerUiControllerProvider.notifier).toggleLock();
  }

  void _cycleFit() {
    final ui = ref.read(playerUiControllerProvider.notifier);
    ui.cycleFit();
    final next = ref.read(playerUiControllerProvider).fit;
    try {
      widget.controller.setOverriddenFit(next);
    } catch (_) {}
  }

  void _onSkipIntro() {
    final end = widget.introEnd;
    if (end == null) return;
    HapticFeedback.lightImpact();
    try {
      widget.controller.seekTo(end);
    } catch (_) {}
  }

  /// Toggle landscape ↔ portrait. Persists by re-applying SystemChrome
  /// preferred orientations + immersive mode every time the state flips.
  void _toggleOrientation() {
    HapticFeedback.selectionClick();
    ref.read(playerUiControllerProvider.notifier).toggleOrientation();
  }

  /// Apply the requested orientation to the OS. In landscape we re-enter
  /// immersive sticky (status / nav bars hidden); in portrait we restore the
  /// system bars so the user can see the time / battery while watching.
  void _applyOrientation(OrientationMode mode) {
    if (mode == OrientationMode.landscape) {
      unawaited(SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]));
      unawaited(
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
      );
    } else {
      unawaited(SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]));
      unawaited(SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      ));
    }
  }

  Future<void> _enterPip() async {
    final key = widget.playerKey;
    if (key == null) return;
    HapticFeedback.selectionClick();
    try {
      await widget.controller.enablePictureInPicture(key);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Picture-in-Picture is not supported on this device.',
          ),
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // React to orientation toggles. `ref.listen` only fires on changes, so
    // the OS-level call doesn't run on every rebuild.
    ref.listen<OrientationMode>(
      playerUiControllerProvider.select((s) => s.orientationMode),
      (prev, next) {
        if (prev == next) return;
        _applyOrientation(next);
      },
    );

    final ui = ref.watch(playerUiControllerProvider);
    final hasPrev = widget.playlist != null && widget.currentIndex > 0;
    final hasNext = widget.playlist != null &&
        widget.currentIndex + 1 < (widget.playlist?.length ?? 0);

    // Pull the live aspect ratio from the video; fall back to 16:9 before
    // the controller initialises. In portrait we letterbox top/bottom so the
    // video keeps its native shape; in landscape we let it fill the surface.
    final inner = widget.controller.videoPlayerController;
    final videoAspect = (inner != null && inner.value.aspectRatio > 0)
        ? inner.value.aspectRatio
        : 16 / 9;
    Widget videoSurface = RepaintBoundary(
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BetterPlayer(
          key: widget.playerKey,
          controller: widget.controller,
        ),
      ),
    );
    if (ui.orientationMode == OrientationMode.portrait) {
      videoSurface = Center(
        child: AspectRatio(aspectRatio: videoAspect, child: videoSurface),
      );
    }

    return ColoredBox(
      color: OttPlayerTokens.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          videoSurface,
          // Single composite gesture layer — every gesture (tap, double-tap,
          // drag, pinch) is recognised here. Combining them in one detector
          // is what makes double-tap reliable; siblings would race in the
          // arena and the scale recogniser would steal half the taps.
          Positioned.fill(
            child: CompositeGestureLayer(
              controller: widget.controller,
              locked: ui.locked,
              totalDuration: _duration,
              currentPosition: () => _position,
              onTap: _onTap,
              onDoubleTap: _onDoubleTap,
              onLevelChanged: _onLevelChanged,
              onLevelEnded: _onLevelEnded,
              onSeekUpdate: _onSeekHud,
              onScale: _onScale,
            ),
          ),
          // Double-tap ripple.
          Positioned.fill(
            child: RepaintBoundary(child: DoubleTapRipple(state: _ripple)),
          ),
          // Buffering / seek preview overlay (centered).
          if (ui.bufferingVisible)
            const Center(child: BufferingIndicator(size: 56)),
          if (_seekHud != null)
            IgnorePointer(
              child: SeekPreviewHud(
                targetPosition: _seekHud!.targetPosition,
                delta: _seekHud!.delta,
                totalDuration: _duration,
              ),
            ),
          if (_levelHud != null)
            IgnorePointer(
              child: VolumeBrightnessHud(
                side: _levelHud!.side,
                value: _levelHud!.value,
              ),
            ),
          // Skip-intro button.
          Positioned(
            right: 0,
            bottom: 0,
            child: SkipIntroButton(
              position: _position,
              introStart: widget.introStart,
              introEnd: widget.introEnd,
              onPressed: _onSkipIntro,
            ),
          ),
          // Top chrome.
          if (!ui.locked)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: _autoHide,
                builder: (context, visible, child) =>
                    FadeOverlay(visible: visible, child: child!),
                child: TopControlsBar(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  orientationMode: ui.orientationMode,
                  onBack: () => Navigator.of(context).maybePop(),
                  onSettings: _openSettings,
                  onLock: _toggleLock,
                  onToggleOrientation: _toggleOrientation,
                ),
              ),
            ),
          // Center cluster.
          if (!ui.locked)
            Positioned.fill(
              child: ValueListenableBuilder<bool>(
                valueListenable: _autoHide,
                builder: (context, visible, _) => FadeOverlay(
                  visible: visible && !_scrubbing,
                  child: Center(
                    child: CenterControls(
                      controller: widget.controller,
                      bufferingVisible: ui.bufferingVisible,
                      onPrevious: hasPrev
                          ? () => widget.onPickEpisode?.call(
                                widget.currentIndex - 1,
                              )
                          : null,
                      onNext: hasNext
                          ? () => widget.onPickEpisode?.call(
                                widget.currentIndex + 1,
                              )
                          : null,
                      onTogglePlay: _togglePlay,
                    ),
                  ),
                ),
              ),
            ),
          // Bottom chrome.
          if (!ui.locked)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: _autoHide,
                builder: (context, visible, child) =>
                    FadeOverlay(visible: visible, child: child!),
                child: BottomControlsBar(
                  controller: widget.controller,
                  fitLabel: ui.fitLabel,
                  speedLabel: ui.speedLabel,
                  qualityLabel: ui.qualityLabel,
                  subtitleLabel: ui.subtitleLabel,
                  episodeListVisible:
                      widget.playlist != null && widget.playlist!.length > 1,
                  pipAvailable: widget.playerKey != null,
                  onCycleFit: _cycleFit,
                  onTapSubtitles: _openSubtitles,
                  onTapSpeed: _openSpeed,
                  onTapQuality: _openQuality,
                  onTapEpisodes: _openEpisodes,
                  onTapPip: _enterPip,
                  onScrubStart: () {
                    setState(() => _scrubbing = true);
                    _autoHide.suspend();
                  },
                  onScrubEnd: () {
                    setState(() => _scrubbing = false);
                    _autoHide.resume();
                  },
                ),
              ),
            ),
          // Lock scrim sits above everything else when active.
          if (ui.locked)
            Positioned.fill(child: LockOverlay(onUnlock: _toggleLock)),
        ],
      ),
    );
  }
}
