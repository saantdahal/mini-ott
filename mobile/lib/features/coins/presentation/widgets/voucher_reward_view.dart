import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';

/// Voucher reward info view widget
class VoucherRewardView extends StatelessWidget {
  final ScreenHelper screen;

  const VoucherRewardView({super.key, required this.screen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screen.paddingAllEdgeInsets,
        vertical: screen.spacing * 0.75,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(12.r),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Icon(
            Icons.card_giftcard,
            size: screen.isMobile ? 28.sp : 32.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: screen.paddingAllEdgeInsets * 0.75),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voucher Reward',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screen.isMobile ? 14.sp : 15.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Every 100 coins = 1 voucher code',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: screen.isMobile ? 12.sp : 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
