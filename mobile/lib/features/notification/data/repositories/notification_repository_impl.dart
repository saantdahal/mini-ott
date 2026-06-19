import 'package:miniott/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:miniott/features/notification/domain/entities/notification.dart';
import 'package:miniott/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remoteDataSource);

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<List<Notification>> getNotifications() {
    return _remoteDataSource.getNotifications();
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(String notificationId) {
    return _remoteDataSource.deleteNotification(notificationId);
  }

  @override
  Future<int> getUnreadCount() {
    return _remoteDataSource.getUnreadCount();
  }
}
