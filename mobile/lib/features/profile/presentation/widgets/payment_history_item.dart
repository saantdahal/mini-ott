import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../../data/models/payment_history_response_model.dart';

class PaymentHistoryItem extends StatelessWidget {
  const PaymentHistoryItem({super.key, required this.item});

  final PaymentHistoryItemModel item;

  Color _statusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (item.status.toLowerCase()) {
      case 'completed':
      case 'success':
        return colorScheme.primary;
      case 'pending':
        return colorScheme.tertiary;
      case 'failed':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  IconData _gatewayIcon() {
    switch (item.gateway.toLowerCase()) {
      case 'khalti':
        return Icons.account_balance_wallet_rounded;
      case 'esewa':
        return Icons.payments_outlined;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(context);
    final paidAt = item.paidAt ?? item.createdAt;
    final packageTitle = item.coinPackage?.title ?? item.paymentFor;
    final coinLabel = item.coinPackage?.coins ?? item.coinsCredited;

    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(screen.isMobile ? 16.r : 18.r),
      child: Container(
        padding: EdgeInsets.all(screen.isMobile ? 14.w : 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screen.isMobile ? 16.r : 18.r),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screen.isMobile ? 46.w : 52.w,
                  height: screen.isMobile ? 46.w : 52.w,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    _gatewayIcon(),
                    color: statusColor,
                    size: screen.isMobile ? 22.sp : 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              packageTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: screen.isMobile ? 14.sp : 15.sp,
                                  ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${item.currency} ${item.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                              fontSize: screen.isMobile ? 14.sp : 15.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        item.gatewayReference ?? item.gateway,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: screen.isMobile ? 11.sp : 12.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _MiniPill(
                            icon: Icons.local_atm_rounded,
                            label: '$coinLabel coins',
                            color: colorScheme.primary,
                          ),
                          _MiniPill(
                            icon: Icons.schedule_rounded,
                            label: _formatDateTime(paidAt),
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: screen.isMobile ? 10.sp : 11.sp,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    item.gateway.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontSize: screen.isMobile ? 10.sp : 11.sp,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    item.gatewayTransactionId ?? item.paymentId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: screen.isMobile ? 10.sp : 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day/${local.year} $hour:$minute';
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
