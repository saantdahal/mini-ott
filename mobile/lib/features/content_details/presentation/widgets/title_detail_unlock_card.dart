import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TitleDetailUnlockCard extends StatelessWidget {
  const TitleDetailUnlockCard({
    super.key,
    required this.coinCost,
    required this.totalEpisodes,
    required this.onUnlock,
  });

  final int coinCost;
  final int totalEpisodes;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "COLLECTOR'S EDITION",
                style: TextStyle(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.w800,
                  fontSize: 10.sp,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.auto_awesome_rounded,
                color: colorScheme.tertiary,
                size: 18.sp,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Unlock All Episodes',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Gain full access to all $totalEpisodes episodes and exclusive behind-the-scenes content.',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13.sp,
              height: 1.45,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onUnlock,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.tertiary,
                foregroundColor: colorScheme.onTertiary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'UNLOCK SEASON FOR $coinCost COINS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12.sp,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
