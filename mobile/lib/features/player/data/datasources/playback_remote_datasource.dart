import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/playback_dtos.dart';

part 'playback_remote_datasource.g.dart';

@RestApi()
abstract class PlaybackRemoteDataSource {
  factory PlaybackRemoteDataSource(Dio dio, {String? baseUrl}) =
      _PlaybackRemoteDataSource;

  @GET('/api/stream/content/{contentId}/hls')
  Future<HlsPlaybackResponse> getContentHlsPlayback(
    @Path('contentId') String contentId,
  );

  @GET('/api/stream/episode/{episodeId}/hls')
  Future<HlsPlaybackResponse> getEpisodeHlsPlayback(
    @Path('episodeId') String episodeId,
  );

  @GET('/api/stream/{videoUploadId}/hls')
  Future<HlsPlaybackResponse> getUploadHlsPlayback(
    @Path('videoUploadId') String videoUploadId,
  );

  @GET('/api/uploads/{id}/play-url')
  Future<Mp4PlaybackResponse> getMp4Playback(@Path('id') String id);
}
