import 'package:miniott/features/notification/domain/entities/notification.dart';
import 'package:miniott/features/notification/domain/entities/notification_type.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.createdAt,
    super.isRead = false,
    super.imageUrl,
    super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.fromValue(json['type'] as String?),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['is_read'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.value,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'image_url': imageUrl,
      'data': data,
    };
  }
}
