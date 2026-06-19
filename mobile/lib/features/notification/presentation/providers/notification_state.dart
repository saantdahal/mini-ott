import '../../domain/entities/notification.dart';

class NotificationState {
  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  final List<Notification> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  NotificationState copyWith({
    List<Notification>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
