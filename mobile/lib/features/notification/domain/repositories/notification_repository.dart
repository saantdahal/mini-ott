import '../entities/notification.dart';

abstract class NotificationRepository {
  /// Fetch all notifications for the current user
  Future<List<Notification>> getNotifications();

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete a notification
  Future<void> deleteNotification(String notificationId);

  /// Get unread notification count
  Future<int> getUnreadCount();
}
