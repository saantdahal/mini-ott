import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/player_di.dart';
import '../../domain/entities/playback_source.dart';
import '../../domain/repositories/playback_repository.dart';

sealed class PlaybackState {
  const PlaybackState();
}

class PlaybackIdle extends PlaybackState {
  const PlaybackIdle();
}

class PlaybackLoading extends PlaybackState {
  const PlaybackLoading();
}

class PlaybackReady extends PlaybackState {
  const PlaybackReady({required this.source, required this.title});

  final PlaybackSource source;
  final String title;
}

class PlaybackNoVideo extends PlaybackState {
  const PlaybackNoVideo();
}

class PlaybackError extends PlaybackState {
  const PlaybackError(this.message);

  final String message;
}

class PlaybackNotifier extends Notifier<PlaybackState> {
  @override
  PlaybackState build() => const PlaybackIdle();

  Future<void> load({
    required String contentId,
    required String title,
    required bool hasManifestKey,
    String? episodeId,
    String? uploadId,
  }) async {
    state = const PlaybackLoading();
    final usecase = ref.read(resolvePlaybackSourceProvider);
    final result = await usecase(
      contentId: contentId,
      hasManifestKey: hasManifestKey,
      episodeId: episodeId,
      uploadId: uploadId,
    );
    state = result.fold<PlaybackState>(
      (failure) => _failureToState(failure),
      (source) => PlaybackReady(source: source, title: title),
    );
  }

  PlaybackState _failureToState(PlaybackFailure failure) {
    return switch (failure) {
      NoVideoFailure() => const PlaybackNoVideo(),
      ForbiddenFailure() => const PlaybackError(
        'You do not have permission to play this video.',
      ),
      NotFoundFailure() => const PlaybackError('Video not found.'),
      UnknownFailure(message: final m) => PlaybackError(m),
    };
  }
}

final playbackNotifierProvider =
    NotifierProvider<PlaybackNotifier, PlaybackState>(PlaybackNotifier.new);
