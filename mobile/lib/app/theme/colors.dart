import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color dsmoViolet = Color(0xFFA855F7);
  static const Color deepViolet = Color(0xFF7C3AED);
  static const Color darkViolet = Color(0xFF4C1D95);
  static const Color tonalViolet = Color(0xFF1E0A3C);
  static const Color plumGray = Color(0xFF6B4F7A);
  static const Color ashPlum = Color(0xFF3D2E4A);
  static const Color obsidian = Color(0xFF0D0A0D);
  static const Color charcoal = Color(0xFF1A1320);
  static const Color darkSlate = Color(0xFF241A2E);
  static const Color smokeDark = Color(0xFF2E2238);
  static const Color coinGold = Color(0xFFFFB400);
  static const Color goldAmber = Color(0xFF3D2A00);
  static const Color goldDeep = Color(0xFF5C3D00);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFEDDFFF);
  static const Color mutedWhite = Color(0xFFB8A8CC);
  static const Color outlineColor = Color(0xFF4A3A5E);
  static const Color outlineVariantColor = Color(0xFF2E1E3C);

  static const Color primary = dsmoViolet;
  static const Color onPrimary = white;
  static const Color primaryContainer = deepViolet;
  static const Color onPrimaryContainer = offWhite;

  static const Color secondary = plumGray;
  static const Color onSecondary = white;
  static const Color secondaryContainer = ashPlum;
  static const Color onSecondaryContainer = offWhite;

  static const Color tertiary = coinGold;
  static const Color onTertiary = black;
  static const Color tertiaryContainer = goldAmber;
  static const Color onTertiaryContainer = coinGold;

  static const Color error = Color(0xFFFF453A);
  static const Color onError = white;
  static const Color errorContainer = Color(0xFF3D0A3A);
  static const Color onErrorContainer = Color(0xFFFFB4AB);

  static const Color surface = obsidian;
  static const Color onSurface = white;
  static const Color surfaceVariant = charcoal;
  static const Color onSurfaceVariant = mutedWhite;

  static const Color surfaceContainerLowest = black;
  static const Color surfaceContainerLow = obsidian;
  static const Color surfaceContainer = charcoal;
  static const Color surfaceContainerHigh = darkSlate;
  static const Color surfaceContainerHighest = smokeDark;

  static const Color background = obsidian;
  static const Color onBackground = white;

  static const Color outline = outlineColor;
  static const Color outlineVariant = outlineVariantColor;

  static const Color inverseSurface = offWhite;
  static const Color onInverseSurface = obsidian;
  static const Color inversePrimary = deepViolet;

  static const Color shadow = black;
  static const Color scrim = black;

  static const Color surfaceTint = dsmoViolet;

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,

    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    primaryFixed: Color(0xFFEDD9FF),
    primaryFixedDim: dsmoViolet,
    onPrimaryFixed: darkViolet,
    onPrimaryFixedVariant: deepViolet,

    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    secondaryFixed: Color(0xFFD9C8E8),
    secondaryFixedDim: plumGray,
    onSecondaryFixed: Color(0xFF1A1020),
    onSecondaryFixedVariant: ashPlum,

    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    tertiaryFixed: Color(0xFFFFE0A0),
    tertiaryFixedDim: coinGold,
    onTertiaryFixed: Color(0xFF1A0D00),
    onTertiaryFixedVariant: goldDeep,

    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,

    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,

    inverseSurface: inverseSurface,
    onInverseSurface: onInverseSurface,
    inversePrimary: inversePrimary,

    outline: outline,
    outlineVariant: outlineVariant,

    shadow: shadow,
    scrim: scrim,
    surfaceTint: surfaceTint,
  );

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,

    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: Color(0xFFEDD9FF),
    onPrimaryContainer: darkViolet,
    primaryFixed: Color(0xFFEDD9FF),
    primaryFixedDim: dsmoViolet,
    onPrimaryFixed: darkViolet,
    onPrimaryFixedVariant: deepViolet,

    secondary: plumGray,
    onSecondary: white,
    secondaryContainer: Color(0xFFEDE0F5),
    onSecondaryContainer: Color(0xFF1A1020),
    secondaryFixed: Color(0xFFEDE0F5),
    secondaryFixedDim: plumGray,
    onSecondaryFixed: Color(0xFF1A1020),
    onSecondaryFixedVariant: ashPlum,

    tertiary: Color(0xFFA06800),
    onTertiary: white,
    tertiaryContainer: Color(0xFFFFE0A0),
    onTertiaryContainer: Color(0xFF1A0D00),
    tertiaryFixed: Color(0xFFFFE0A0),
    tertiaryFixedDim: Color(0xFFFFB400),
    onTertiaryFixed: Color(0xFF1A0D00),
    onTertiaryFixedVariant: goldDeep,

    error: Color(0xFFBA1A1A),
    onError: white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),

    surface: white,
    onSurface: Color(0xFF1A1020),
    onSurfaceVariant: plumGray,
    surfaceContainerLowest: white,
    surfaceContainerLow: Color(0xFFF8F4FF),
    surfaceContainer: Color(0xFFF2ECFA),
    surfaceContainerHigh: Color(0xFFE9E0F5),
    surfaceContainerHighest: Color(0xFFDED4ED),

    inverseSurface: Color(0xFF1A1020),
    onInverseSurface: Color(0xFFF2ECFA),
    inversePrimary: Color(0xFFD09EFF),

    outline: plumGray,
    outlineVariant: Color(0xFFD4C5E5),

    shadow: black,
    scrim: black,
    surfaceTint: dsmoViolet,
  );
}
