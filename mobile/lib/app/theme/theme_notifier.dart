import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/token_storage_service.dart';
import '../../core/di/di.dart';

/// Enum for available theme modes
enum AppThemeMode { light, dark, system }

extension AppThemeModeExt on AppThemeMode {
  ThemeMode toThemeMode() {
    return switch (this) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }

  String get label {
    return switch (this) {
      AppThemeMode.light => 'Light',
      AppThemeMode.dark => 'Dark',
      AppThemeMode.system => 'System',
    };
  }

  String get storageKey => 'app_theme_mode';
}

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    // Start with default, then load from storage asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTheme();
    });
    return AppThemeMode.system; // default
  }

  Future<void> _loadTheme() async {
    try {
      final tokenService = getIt<TokenStorageService>();
      final savedTheme = await tokenService.getTheme();
      if (savedTheme != null) {
        state = _parseTheme(savedTheme);
      }
    } catch (e) {
      // Silently fail, keep default
    }
  }

  AppThemeMode _parseTheme(String value) {
    return switch (value) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      'system' => AppThemeMode.system,
      _ => AppThemeMode.system,
    };
  }

  Future<void> setTheme(AppThemeMode themeMode) async {
    state = themeMode;
    try {
      final tokenService = getIt<TokenStorageService>();
      await tokenService.saveTheme(themeMode.name);
    } catch (e) {
      // Silently fail - UI already updated
    }
  }
}

/// Riverpod provider for theme mode
final themeNotifierProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  () => ThemeNotifier(),
);

/// Family provider to get ThemeMode directly (for MaterialApp)
final themeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(themeNotifierProvider);
  return appThemeMode.toThemeMode();
});
