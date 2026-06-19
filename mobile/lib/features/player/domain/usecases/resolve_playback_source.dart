import 'package:dartz/dartz.dart';

import '../entities/playback_source.dart';
import '../repositories/playback_repository.dart';

class ResolvePlaybackSource {
  ResolvePlaybackSource(this._repository);

  final PlaybackRepository _repository;
  Future<Either<PlaybackFailure, PlaybackSource>> call({
    required String contentId,
    required bool hasManifestKey,
    String? episodeId,
    String? uploadId,
  }) async {
    if (hasManifestKey) {
      final hls = (episodeId != null && episodeId.isNotEmpty)
          ? await _repository.getEpisodeHlsManifestUrl(episodeId)
          : await _repository.getContentHlsManifestUrl(contentId);
      final hlsResult = hls.fold<Either<PlaybackFailure, PlaybackSource>?>(
        (failure) {
          if (failure is ForbiddenFailure ||
              failure is NoVideoFailure ||
              failure is NotFoundFailure) {
            return null;
          }
          return Left(failure);
        },
        (manifestUrl) =>
            Right(HlsSource(manifestUrl: manifestUrl, expiresIn: 0)),
      );
      if (hlsResult != null) return hlsResult;
    }

    if (uploadId != null && uploadId.isNotEmpty) {
      // First try HLS directly for this upload (server supports /api/stream/:videoUploadId/hls)
      final uploadHls = await _repository.getUploadHlsManifestUrl(uploadId);
      final uploadHlsResult = uploadHls
          .fold<Either<PlaybackFailure, PlaybackSource>?>(
            (failure) {
              if (failure is ForbiddenFailure ||
                  failure is NoVideoFailure ||
                  failure is NotFoundFailure) {
                return null; // allow fallback to MP4
              }
              return Left(failure);
            },
            (manifestUrl) =>
                Right(HlsSource(manifestUrl: manifestUrl, expiresIn: 0)),
          );

      if (uploadHlsResult != null) return uploadHlsResult;

      final mp4 = await _repository.getMp4Url(uploadId);
      return mp4.map((url) => Mp4Source(url: url, expiresIn: 0));
    }

    return const Left(NoVideoFailure());
  }
}
