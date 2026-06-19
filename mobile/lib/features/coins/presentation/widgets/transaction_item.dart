import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';

/// Transaction history item widget - Modern Design
class TransactionItem extends StatelessWidget {
  final String type;
  final int amount;
  final String status;
  final DateTime date;
  final String? description;

  const TransactionItem({
    super.key,
    required this.type,
    required this.amount,
    required this.status,
    required this.date,
    this.description,
  });

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
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

  IconData _getTypeIcon() {
    switch (type) {
      case 'purchase':
        return Icons.shopping_cart;
      case 'reward':
        return Icons.card_giftcard;
      case 'usage':
        return Icons.local_activity;
      default:
        return Icons.monetization_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final statusColor = _getStatusColor(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screen.isMobile ? 14.w : 16.w,
        vertical: screen.isMobile ? 14.h : 16.h,
      ),
      margin: EdgeInsets.only(bottom: screen.isMobile ? 10.h : 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(screen.isMobile ? 14.r : 16.r),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: EdgeInsets.all(screen.isMobile ? 10.r : 12.r),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Icon(
              _getTypeIcon(),
              size: screen.isMobile ? 20.sp : 24.sp,
              color: statusColor,
            ),
          ),
          SizedBox(width: screen.isMobile ? 12.w : 16.w),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${type[0].toUpperCase()}${type.substring(1)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screen.isMobile ? 12.sp : 13.sp,
                  ),
                ),
                SizedBox(height: screen.isMobile ? 5.h : 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: screen.isMobile ? 12.sp : 14.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 3.w),
                    Flexible(
                      child: Text(
                        '+$amount coins',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: screen.isMobile ? 11.sp : 12.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: screen.isMobile ? 8.w : 12.w),
                    Icon(
                      Icons.schedule,
                      size: screen.isMobile ? 12.sp : 14.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 3.w),
                    Flexible(
                      child: Text(
                        _formatDate(date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: screen.isMobile ? 10.sp : 11.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: screen.isMobile ? 8.w : 12.w),
          // Status badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screen.isMobile ? 8.w : 10.w,
              vertical: screen.isMobile ? 5.h : 6.h,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(screen.isMobile ? 6.r : 8.r),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              status[0].toUpperCase() + status.substring(1),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: screen.isMobile ? 9.sp : 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && difference.inHours < 24) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
