import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../../domain/entities/coin_package.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final primary = cs.primary;
    final bonusFg = cs.tertiary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: isSelected ? primary.withValues(alpha: 0.06) : cs.surface,
          border: Border.all(
            color: isSelected
                ? primary
                : cs.outlineVariant.withValues(alpha: 0.6),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reserve the top-right corner for the popular/check badge.
                  Padding(
                    padding: EdgeInsets.only(right: 26.w),
                    child: Text(
                      package.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        fontSize: screen.isMobile ? 13.sp : 14.sp,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  if (package.description != null &&
                      package.description!.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      package.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: screen.isMobile ? 11.sp : 11.5.sp,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  SizedBox(height: 10.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.monetization_on_rounded,
                        color: primary,
                        size: screen.isMobile ? 22.sp : 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '${package.coins}',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w900,
                              fontSize: screen.isMobile ? 26.sp : 28.sp,
                              letterSpacing: -0.7,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (package.bonusCoins > 0) ...[
                    SizedBox(height: 6.h),
                    Text(
                      '+${package.bonusCoins} bonus coins',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: bonusFg,
                        fontWeight: FontWeight.w700,
                        fontSize: screen.isMobile ? 11.sp : 12.sp,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                  Text(
                    '${package.currency} ${package.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: screen.isMobile ? 15.sp : 16.sp,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: _CornerBadge(
                isSelected: isSelected,
                isPopular: package.isPopular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerBadge extends StatelessWidget {
  const _CornerBadge({required this.isSelected, required this.isPopular});

  final bool isSelected;
  final bool isPopular;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (isSelected) {
      return Container(
        width: 22.r,
        height: 22.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.primary,
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.check_rounded, size: 14.r, color: cs.onPrimary),
      );
    }
    if (isPopular) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'POPULAR',
          style: TextStyle(
            color: cs.onPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 9.sp,
            letterSpacing: 0.6,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
