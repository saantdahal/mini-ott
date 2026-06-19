import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final bool lightOnDark;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.lightOnDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final theme = Theme.of(context);

    final titleColor = lightOnDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface;
    final subColor = lightOnDark
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurfaceVariant;
    final linkColor = lightOnDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: screen.isMobile ? 17.sp : 19.sp,
                  letterSpacing: -0.2,
                  color: titleColor,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                SizedBox(height: 5.h),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subColor,
                    fontSize: screen.isMobile ? 12.sp : 13.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: linkColor,
              padding: EdgeInsets.only(left: 8.w, top: 0, bottom: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'See All',
              style: theme.textTheme.labelLarge?.copyWith(
                color: linkColor.withValues(alpha: lightOnDark ? 0.85 : 1),
                fontWeight: FontWeight.w600,
                fontSize: screen.isMobile ? 13.sp : 14.sp,
              ),
            ),
          ),
      ],
    );
  }
}
