import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/playback_remote_datasource.dart';
import '../data/local/watch_progress_local_datasource.dart';
import '../data/repositories/playback_repository_impl.dart';
import '../domain/repositories/playback_repository.dart';
import '../domain/repositories/watch_progress_repository.dart';
import '../domain/usecases/resolve_playback_source.dart';

final getIt = GetIt.instance;

class PlayerDI {
  static void setup() {
    if (!getIt.isRegistered<PlaybackRemoteDataSource>()) {
      getIt.registerLazySingleton<PlaybackRemoteDataSource>(
        () => PlaybackRemoteDataSource(getIt<Dio>()),
      );
    }

    if (!getIt.isRegistered<PlaybackRepository>()) {
      getIt.registerLazySingleton<PlaybackRepository>(
        () => PlaybackRepositoryImpl(getIt<PlaybackRemoteDataSource>()),
      );
    }

    if (!getIt.isRegistered<ResolvePlaybackSource>()) {
      getIt.registerLazySingleton<ResolvePlaybackSource>(
        () => ResolvePlaybackSource(getIt<PlaybackRepository>()),
      );
    }

    if (!getIt.isRegistered<WatchProgressRepository>()) {
      getIt.registerLazySingleton<WatchProgressRepository>(
        () => WatchProgressLocalDataSource(),
      );
    }
  }
}

final playbackRepositoryProvider = Provider<PlaybackRepository>(
  (ref) => getIt<PlaybackRepository>(),
);

final resolvePlaybackSourceProvider = Provider<ResolvePlaybackSource>(
  (ref) => getIt<ResolvePlaybackSource>(),
);

final watchProgressRepositoryProvider = Provider<WatchProgressRepository>(
  (ref) => getIt<WatchProgressRepository>(),
);
