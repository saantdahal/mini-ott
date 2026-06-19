import 'package:flutter/material.dart';

/// Design tokens for the immersive OTT player chrome. The player surface is
/// always dark regardless of the host app's theme — matches Netflix / Prime /
/// MX behaviour and keeps content readable over the video texture.
class OttPlayerTokens {
  const OttPlayerTokens._();

  // Surfaces & scrims
  static const Color surface = Color(0xFF000000);
  static const Color elevatedSurface = Color(0xFF141218);
  static const Color sheetSurface = Color(0xFF1B1B1F);
  static const Color scrimTop = Color(0xCC000000);
  static const Color scrimBottom = Color(0xE6000000);
  static const Color scrimSheet = Color(0xB3000000);

  // Foregrounds
  static const Color text = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB8A8CC);
  static const Color textFaint = Color(0xFF8A7E9A);
  static const Color iconActive = Color(0xFFFFFFFF);
  static const Color iconInactive = Color(0xFFB8A8CC);

  // Accents (mirrors AppColors but kept independent so the player never picks
  // up surprise tokens from the app theme).
  static const Color accent = Color(0xFFA855F7);
  static const Color accentSoft = Color(0xFFD09EFF);
  static const Color accentDeep = Color(0xFF7C3AED);

  // Geometry
  static const Duration fadeDuration = Duration(milliseconds: 220);
  static const Duration autoHideDelay = Duration(seconds: 4);
  static const Duration rippleDuration = Duration(milliseconds: 600);
  static const Duration hudDismissDelay = Duration(milliseconds: 700);
  static const Duration positionPollInterval = Duration(milliseconds: 200);
  static const Duration progressSaveInterval = Duration(seconds: 5);

  static const int doubleTapSeekStepSeconds = 10;

  // Reusable gradient for top/bottom chromes.
  static const LinearGradient topScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [scrimTop, Color(0x00000000)],
  );

  static const LinearGradient bottomScrim = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [scrimBottom, Color(0x00000000)],
  );

  static const LinearGradient progressFill = LinearGradient(
    colors: [accent, accentSoft],
  );
}
