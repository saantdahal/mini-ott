import 'package:get_it/get_it.dart';
import 'package:miniott/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:miniott/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:miniott/features/notification/domain/repositories/notification_repository.dart';
import 'package:miniott/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:miniott/features/notification/domain/usecases/get_unread_count_usecase.dart';
import 'package:miniott/features/notification/domain/usecases/mark_notification_as_read_usecase.dart';

final getIt = GetIt.instance;

class NotificationDI {
  static void setup() {
    // Data Sources
    getIt.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(),
    );

    // Repositories
    getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(getIt<NotificationRemoteDataSource>()),
    );

    // Use Cases
    getIt.registerLazySingleton<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(getIt<NotificationRepository>()),
    );

    getIt.registerLazySingleton<MarkNotificationAsReadUseCase>(
      () => MarkNotificationAsReadUseCase(getIt<NotificationRepository>()),
    );

    getIt.registerLazySingleton<GetUnreadCountUseCase>(
      () => GetUnreadCountUseCase(getIt<NotificationRepository>()),
    );
  }
}
