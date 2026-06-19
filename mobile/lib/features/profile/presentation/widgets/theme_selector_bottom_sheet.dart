import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/theme_notifier.dart';

class ThemeSelectorBottomSheet extends StatelessWidget {
  final AppThemeMode currentTheme;
  final ValueChanged<AppThemeMode> onThemeSelected;

  const ThemeSelectorBottomSheet({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 12.h, 0, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Select Theme',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ...AppThemeMode.values.map((theme) {
              final isSelected = theme == currentTheme;
              return _ThemeOption(
                theme: theme,
                isSelected: isSelected,
                onTap: () {
                  onThemeSelected(theme);
                  Navigator.pop(context);
                },
              );
            }),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final AppThemeMode theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon(AppThemeMode theme) {
    return switch (theme) {
      AppThemeMode.light => Icons.light_mode_rounded,
      AppThemeMode.dark => Icons.dark_mode_rounded,
      AppThemeMode.system => Icons.brightness_auto_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  _getIcon(theme),
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  theme.label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.primary,
                  size: 22.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
