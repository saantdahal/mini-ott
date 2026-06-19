import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/repositories/playback_repository.dart';
import '../datasources/playback_remote_datasource.dart';

class PlaybackRepositoryImpl implements PlaybackRepository {
  PlaybackRepositoryImpl(this._remote);

  final PlaybackRemoteDataSource _remote;

  @override
  Future<Either<PlaybackFailure, String>> getContentHlsManifestUrl(
    String contentId,
  ) async {
    try {
      final res = await _remote.getContentHlsPlayback(contentId);
      final url = res.data?.manifestUrl;
      if (url == null || url.isEmpty) {
        return const Left(NoVideoFailure());
      }
      return Right(url);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<PlaybackFailure, String>> getEpisodeHlsManifestUrl(
    String episodeId,
  ) async {
    try {
      final res = await _remote.getEpisodeHlsPlayback(episodeId);
      final url = res.data?.manifestUrl;
      if (url == null || url.isEmpty) {
        return const Left(NoVideoFailure());
      }
      return Right(url);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<PlaybackFailure, String>> getMp4Url(String uploadId) async {
    try {
      final res = await _remote.getMp4Playback(uploadId);
      final url = res.data?.url;
      if (url == null || url.isEmpty) {
        return const Left(NoVideoFailure());
      }
      return Right(url);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<PlaybackFailure, String>> getUploadHlsManifestUrl(
    String uploadId,
  ) async {
    try {
      final res = await _remote.getUploadHlsPlayback(uploadId);
      final url = res.data?.manifestUrl;
      if (url == null || url.isEmpty) {
        return const Left(NoVideoFailure());
      }
      return Right(url);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  PlaybackFailure _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 403) return const ForbiddenFailure();
    if (status == 404) return const NotFoundFailure();
    return UnknownFailure(userFriendlyMessageFromDio(e));
  }
}
