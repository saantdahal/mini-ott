import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniott/core/di/di.dart';
import 'package:miniott/features/notification/domain/repositories/notification_repository.dart';
import 'package:miniott/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:miniott/features/notification/domain/usecases/get_unread_count_usecase.dart';
import 'package:miniott/features/notification/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:miniott/features/notification/presentation/providers/notification_notifier.dart';
import 'package:miniott/features/notification/presentation/providers/notification_state.dart';

export 'notification_notifier.dart';
export 'notification_state.dart';

/// Repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => getIt<NotificationRepository>(),
);

/// Use case providers
final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>(
  (ref) => getIt<GetNotificationsUseCase>(),
);

final markNotificationAsReadUseCaseProvider =
    Provider<MarkNotificationAsReadUseCase>(
      (ref) => getIt<MarkNotificationAsReadUseCase>(),
    );

final getUnreadCountUseCaseProvider = Provider<GetUnreadCountUseCase>(
  (ref) => getIt<GetUnreadCountUseCase>(),
);

/// Notifier Provider
final notificationNotifierProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
      NotificationNotifier.new,
    );
