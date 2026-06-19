import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the player is locked to landscape (default), forced into portrait,
/// or following the device's natural orientation.
enum OrientationMode { landscape, portrait }

/// Immutable snapshot of every piece of player-UI state that lives outside the
/// `BetterPlayerController`. Kept tiny + value-equal so listeners only rebuild
/// when something they care about actually changed.
class PlayerUiState {
  const PlayerUiState({
    this.locked = false,
    this.fitIndex = 0,
    this.speed = 1.0,
    this.bufferingVisible = false,
    this.activeSheet = ActiveSheet.none,
    this.subtitleVisible = true,
    this.qualityLabel = 'Auto',
    this.subtitleLabel = 'Off',
    this.audioLabel = 'Default',
    this.orientationMode = OrientationMode.landscape,
  });

  final bool locked;
  final int fitIndex;
  final double speed;
  final bool bufferingVisible;
  final ActiveSheet activeSheet;
  final bool subtitleVisible;

  /// Human-readable label for the currently selected variant. The selection
  /// itself lives inside `BetterPlayerController`; we mirror just the label
  /// so the bottom bar / settings sheet can render it without inspecting the
  /// controller on every frame.
  final String qualityLabel;
  final String subtitleLabel;
  final String audioLabel;

  final OrientationMode orientationMode;

  static const fits = <BoxFit>[BoxFit.contain, BoxFit.cover, BoxFit.fill];
  static const fitLabels = <String>['Fit', 'Crop', 'Stretch'];

  BoxFit get fit => fits[fitIndex % fits.length];
  String get fitLabel => fitLabels[fitIndex % fitLabels.length];
  String get speedLabel => speed == 1.0 ? '1×' : '$speed×';

  PlayerUiState copyWith({
    bool? locked,
    int? fitIndex,
    double? speed,
    bool? bufferingVisible,
    ActiveSheet? activeSheet,
    bool? subtitleVisible,
    String? qualityLabel,
    String? subtitleLabel,
    String? audioLabel,
    OrientationMode? orientationMode,
  }) {
    return PlayerUiState(
      locked: locked ?? this.locked,
      fitIndex: fitIndex ?? this.fitIndex,
      speed: speed ?? this.speed,
      bufferingVisible: bufferingVisible ?? this.bufferingVisible,
      activeSheet: activeSheet ?? this.activeSheet,
      subtitleVisible: subtitleVisible ?? this.subtitleVisible,
      qualityLabel: qualityLabel ?? this.qualityLabel,
      subtitleLabel: subtitleLabel ?? this.subtitleLabel,
      audioLabel: audioLabel ?? this.audioLabel,
      orientationMode: orientationMode ?? this.orientationMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlayerUiState &&
      other.locked == locked &&
      other.fitIndex == fitIndex &&
      other.speed == speed &&
      other.bufferingVisible == bufferingVisible &&
      other.activeSheet == activeSheet &&
      other.subtitleVisible == subtitleVisible &&
      other.qualityLabel == qualityLabel &&
      other.subtitleLabel == subtitleLabel &&
      other.audioLabel == audioLabel &&
      other.orientationMode == orientationMode;

  @override
  int get hashCode => Object.hash(
        locked,
        fitIndex,
        speed,
        bufferingVisible,
        activeSheet,
        subtitleVisible,
        qualityLabel,
        subtitleLabel,
        audioLabel,
        orientationMode,
      );
}

enum ActiveSheet { none, settings, speed, quality, subtitles, audio, episodes }

class PlayerUiController extends Notifier<PlayerUiState> {
  @override
  PlayerUiState build() => const PlayerUiState();

  void toggleLock() => state = state.copyWith(locked: !state.locked);

  void cycleFit() {
    final next = (state.fitIndex + 1) % PlayerUiState.fits.length;
    state = state.copyWith(fitIndex: next);
  }

  void setFitIndex(int index) {
    if (index == state.fitIndex) return;
    state = state.copyWith(fitIndex: index % PlayerUiState.fits.length);
  }

  void setSpeed(double speed) => state = state.copyWith(speed: speed);

  void setBuffering(bool visible) {
    if (visible == state.bufferingVisible) return;
    state = state.copyWith(bufferingVisible: visible);
  }

  void openSheet(ActiveSheet sheet) =>
      state = state.copyWith(activeSheet: sheet);
  void closeSheet() => state = state.copyWith(activeSheet: ActiveSheet.none);

  void toggleSubtitleVisibility() =>
      state = state.copyWith(subtitleVisible: !state.subtitleVisible);

  void setQualityLabel(String label) =>
      state = state.copyWith(qualityLabel: label);
  void setSubtitleLabel(String label) =>
      state = state.copyWith(subtitleLabel: label);
  void setAudioLabel(String label) =>
      state = state.copyWith(audioLabel: label);

  void toggleOrientation() => state = state.copyWith(
        orientationMode: state.orientationMode == OrientationMode.landscape
            ? OrientationMode.portrait
            : OrientationMode.landscape,
      );
}

final playerUiControllerProvider =
    NotifierProvider.autoDispose<PlayerUiController, PlayerUiState>(
  PlayerUiController.new,
);
