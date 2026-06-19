import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  Future<List<Notification>> call() {
    return _repository.getNotifications();
  }
}
