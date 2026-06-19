import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_query.dart';

/// Current balance display widget
class BalanceDisplay extends StatelessWidget {
  final int currentBalance;

  const BalanceDisplay({super.key, required this.currentBalance});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screen.paddingAllEdgeInsets,
        vertical: screen.spacing,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.3),
            blurRadius: screen.isMobile ? 16 : 24,
            spreadRadius: screen.isMobile ? 0 : 2,
            offset: Offset(0, screen.isMobile ? 4 : 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            padding: EdgeInsets.all(screen.isMobile ? 12.r : 16.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.onPrimary.withValues(alpha: 0.2),
              border: Border.all(
                color: colorScheme.onPrimary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.monetization_on,
              size: screen.isMobile ? 40.sp : 48.sp,
              color: colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: screen.spacing),
          // Balance Amount
          Text(
            currentBalance.toString(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
              letterSpacing: 1,
              fontSize: screen.isMobile ? 36.sp : 42.sp,
            ),
          ),
          SizedBox(height: screen.spacing * 0.5),
          // Balance Label
          Text(
            'CURRENT BALANCE',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontSize: screen.isMobile ? 11.sp : 12.sp,
            ),
          ),
          SizedBox(height: screen.spacing * 0.75),
          // Optional: Subtle info text
          Text(
            'Earn more coins by watching content',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
              fontSize: screen.isMobile ? 10.sp : 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
