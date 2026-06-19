import 'package:miniott/features/notification/data/models/notification_model.dart';
import 'package:miniott/features/notification/domain/entities/notification_type.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<int> getUnreadCount();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  // Mock data store
  final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: '1',
      title: 'New Movie: Avatar',
      message: 'A new blockbuster movie has been added to our collection',
      type: NotificationType.newContent,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      imageUrl: 'https://via.placeholder.com/300x200?text=Avatar',
    ),
    NotificationModel(
      id: '2',
      title: 'New Series: Stranger Things S5',
      message: 'The latest season of your favorite series is now available',
      type: NotificationType.newContent,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      imageUrl: 'https://via.placeholder.com/300x200?text=Stranger+Things',
    ),
    NotificationModel(
      id: '3',
      title: 'Vote Now: Best Movie of 2026',
      message: 'Cast your vote for the best movie and win rewards',
      type: NotificationType.voting,
      createdAt: DateTime.now().subtract(const Duration(hours: 24)),
      isRead: true,
      imageUrl: 'https://via.placeholder.com/300x200?text=Voting',
    ),
    NotificationModel(
      id: '4',
      title: 'Payment Successful',
      message: 'Your premium subscription has been activated',
      type: NotificationType.payment,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: '5',
      title: 'Special Offer: 50% Off',
      message: 'Limited time offer - Get 50% off on annual subscription',
      type: NotificationType.promotion,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationModel(
      id: '6',
      title: 'System Maintenance',
      message: 'We will be performing system maintenance on Sunday at 2 AM',
      type: NotificationType.system,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockNotifications;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _mockNotifications[index] =
          _mockNotifications[index].copyWith(isRead: true) as NotificationModel;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockNotifications.replaceRange(
      0,
      _mockNotifications.length,
      _mockNotifications.map(
        (n) => n.copyWith(isRead: true) as NotificationModel,
      ),
    );
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockNotifications.removeWhere((n) => n.id == notificationId);
  }

  @override
  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockNotifications.where((n) => !n.isRead).length;
  }
}
