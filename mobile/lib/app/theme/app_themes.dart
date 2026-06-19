import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppThemes {
  const AppThemes._();

  static ThemeData buildDarkTheme() {
    final darkTextTheme =
        GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: AppColors.darkColorScheme.onSurface,
          displayColor: AppColors.darkColorScheme.onSurface,
        );

    return ThemeData(
      colorScheme: AppColors.darkColorScheme,
      scaffoldBackgroundColor: AppColors.darkColorScheme.surface,
      useMaterial3: true,
      textTheme: darkTextTheme,
      cardColor: AppColors.darkColorScheme.surfaceContainer,
      dividerColor: AppColors.darkColorScheme.outlineVariant,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkColorScheme.inverseSurface,
        contentTextStyle: darkTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkColorScheme.onInverseSurface,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkColorScheme.surfaceContainerHigh,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkColorScheme.surfaceContainerHigh,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkColorScheme.surface,
        foregroundColor: AppColors.darkColorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: darkTextTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkColorScheme.primary,
          foregroundColor: AppColors.darkColorScheme.onPrimary,
          disabledBackgroundColor: AppColors.darkColorScheme.primary.withValues(
            alpha: 0.45,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.darkColorScheme.primary.withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: AppColors.darkColorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  static ThemeData buildLightTheme() {
    final lightTextTheme =
        GoogleFonts.montserratTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: AppColors.lightColorScheme.onSurface,
          displayColor: AppColors.lightColorScheme.onSurface,
        );

    return ThemeData(
      colorScheme: AppColors.lightColorScheme,
      scaffoldBackgroundColor: AppColors.lightColorScheme.surface,
      useMaterial3: true,
      textTheme: lightTextTheme,
      cardColor: AppColors.lightColorScheme.surfaceContainer,
      dividerColor: AppColors.lightColorScheme.outlineVariant,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightColorScheme.inverseSurface,
        contentTextStyle: lightTextTheme.bodyMedium?.copyWith(
          color: AppColors.lightColorScheme.onInverseSurface,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightColorScheme.surfaceContainerHigh,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightColorScheme.surfaceContainerHigh,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightColorScheme.surface,
        foregroundColor: AppColors.lightColorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: lightTextTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightColorScheme.primary,
          foregroundColor: AppColors.lightColorScheme.onPrimary,
          disabledBackgroundColor: AppColors.lightColorScheme.primary
              .withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lightColorScheme.primary.withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: AppColors.lightColorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
