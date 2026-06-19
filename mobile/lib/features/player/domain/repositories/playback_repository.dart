import 'package:dartz/dartz.dart';

sealed class PlaybackFailure {
  const PlaybackFailure();
}

class ForbiddenFailure extends PlaybackFailure {
  const ForbiddenFailure();
}

class NotFoundFailure extends PlaybackFailure {
  const NotFoundFailure();
}

class NoVideoFailure extends PlaybackFailure {
  const NoVideoFailure();
}

class UnknownFailure extends PlaybackFailure {
  const UnknownFailure(this.message);

  final String message;
}

abstract class PlaybackRepository {
  /// Returns the signed HLS manifest URL for a content (movie).
  Future<Either<PlaybackFailure, String>> getContentHlsManifestUrl(
    String contentId,
  );

  /// Returns the signed HLS manifest URL for a series episode.
  Future<Either<PlaybackFailure, String>> getEpisodeHlsManifestUrl(
    String episodeId,
  );

  /// Returns the signed HLS manifest URL for a raw video upload (video_uploads.id).
  Future<Either<PlaybackFailure, String>> getUploadHlsManifestUrl(
    String uploadId,
  );

  /// Returns the signed MP4 URL for a video upload.
  Future<Either<PlaybackFailure, String>> getMp4Url(String uploadId);
}
