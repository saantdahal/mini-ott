import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../../domain/entities/coin_package.dart';

/// Compact coin package card widget
class CoinPackageCard extends StatelessWidget {
  final CoinPackage package;
  final bool isSelected;
  final VoidCallback onTap;

  const CoinPackageCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final secondary = colorScheme.secondary;
    final surface = colorScheme.surfaceContainerHigh;
    final onSurface = colorScheme.onSurface;
    final surfaceVariant = colorScheme.outlineVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: screen.isMobile ? 0.3.w : 0.5.w,
            vertical: screen.isMobile ? 0.3.h : 0.5.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screen.isMobile ? 8.r : 10.r),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? primary.withValues(alpha: 0.3)
                    : onSurface.withValues(alpha: 0.1),
                blurRadius: isSelected ? 12 : 8,
                offset: Offset(0, isSelected ? 2 : 1),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screen.isMobile ? 8.r : 10.r),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        primary.withValues(alpha: 0.1),
                        primary.withValues(alpha: 0.05),
                      ],
                    )
                  : LinearGradient(
                      colors: [surface, surface.withValues(alpha: 0.9)],
                    ),
              border: Border.all(
                color: isSelected
                    ? primary.withValues(alpha: 0.5)
                    : surfaceVariant.withValues(alpha: 0.4),
                width: isSelected ? 2 : 1,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: screen.isMobile ? 1.r : 1.2.r,
              vertical: screen.isMobile ? 0.5.r : 0.6.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Expanded(
                  flex: 2,
                  child: Text(
                    package.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                      fontSize: screen.isMobile ? 9.sp : 10.sp,
                    ),
                  ),
                ),
                SizedBox(width: 0.8.w),

                // Popular badge
                if (package.isPopular)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 1.5.w,
                      vertical: 0.3.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primary.withValues(alpha: 0.9),
                          secondary.withValues(alpha: 0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 5.sp,
                          color: colorScheme.onPrimary,
                        ),
                        SizedBox(width: 0.3.w),
                        Text(
                          'Hot',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 5.sp,
                              ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(width: 0.8.w),

                // Coins
                Icon(Icons.monetization_on, size: 8.sp, color: primary),
                SizedBox(width: 0.5.w),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${package.coins}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 8.sp,
                    ),
                  ),
                ),

                // Bonus coins
                if (package.bonusCoins > 0)
                  Text(
                    '+${package.bonusCoins}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 5.sp,
                    ),
                  ),
                SizedBox(width: 0.8.w),

                // Price
                Expanded(
                  flex: 1,
                  child: Text(
                    '${package.currency}${package.price.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 8.sp,
                    ),
                  ),
                ),
                SizedBox(width: 0.6.w),

                // Selection checkbox
                Container(
                  width: 11.r,
                  height: 11.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? LinearGradient(colors: [primary, secondary])
                        : null,
                    color: isSelected
                        ? null
                        : surfaceVariant.withValues(alpha: 0.4),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.surface.withValues(alpha: 0.0)
                          : surfaceVariant.withValues(alpha: 0.7),
                      width: 0.8,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 5.sp,
                          color: colorScheme.onPrimary,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
