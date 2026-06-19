import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniott/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:miniott/features/notification/domain/usecases/get_unread_count_usecase.dart';
import 'package:miniott/features/notification/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:miniott/features/notification/presentation/providers/notification_state.dart';
import 'package:miniott/core/di/di.dart';

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() => const NotificationState();

  Future<void> fetchNotifications() async {
    final getNotificationsUseCase = getIt<GetNotificationsUseCase>();
    final getUnreadCountUseCase = getIt<GetUnreadCountUseCase>();

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final notifications = await getNotificationsUseCase();
      final unreadCount = await getUnreadCountUseCase();
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final markNotificationAsReadUseCase =
        getIt<MarkNotificationAsReadUseCase>();
    try {
      await markNotificationAsReadUseCase(notificationId);
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final updatedNotifications = state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
