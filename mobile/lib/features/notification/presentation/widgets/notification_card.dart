import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:miniott/features/notification/domain/entities/notification.dart'
    as notification_entity;
import 'package:miniott/features/notification/domain/entities/notification_type.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  final notification_entity.Notification notification;
  final VoidCallback? onTap;
  final Function(String)? onDismiss;

  IconData _getIconForType(NotificationType type) {
    return switch (type) {
      NotificationType.newContent => Icons.new_releases_outlined,
      NotificationType.voting => Icons.how_to_vote_outlined,
      NotificationType.payment => Icons.payment_outlined,
      NotificationType.promotion => Icons.local_offer_outlined,
      NotificationType.system => Icons.info_outlined,
      NotificationType.other => Icons.notifications_outlined,
    };
  }

  Color _getColorForType(NotificationType type, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (type) {
      NotificationType.newContent => colorScheme.primary,
      NotificationType.voting => colorScheme.secondary,
      NotificationType.payment => colorScheme.tertiary,
      NotificationType.promotion => colorScheme.primaryContainer,
      NotificationType.system => colorScheme.onSurfaceVariant,
      NotificationType.other => colorScheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('MMM d, h:mm a');
    final color = _getColorForType(notification.type, context);
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(notification.id),
      onDismissed: (_) => onDismiss?.call(notification.id),
      background: Container(
        color: colorScheme.error.withValues(alpha: 0.7),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: notification.isRead
                ? colorScheme.surface
                : colorScheme.primary.withValues(alpha: 0.05),
            border: Border.all(
              color: notification.isRead
                  ? colorScheme.outline.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Icon(
                      _getIconForType(notification.type),
                      color: color,
                      size: 24.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (!notification.isRead)
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        timeFormat.format(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
