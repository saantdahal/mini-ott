import '../entities/hls_playback_entity.dart';
import '../repositories/content_catalog_repository.dart';

class GetHlsPlaybackUseCase {
  GetHlsPlaybackUseCase(this._repository);

  final ContentCatalogRepository _repository;

  Future<HlsPlaybackEntity> call(String videoUploadId) =>
      _repository.getHlsPlaybackParams(videoUploadId);
}
