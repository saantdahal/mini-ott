import '../../../content_details/domain/entities/title_detail.dart';
import '../../../home/domain/entities/content_entity.dart';
import '../../../search/domain/entities/search_result.dart';
import '../entities/category_entity.dart';
import '../entities/episode_entity.dart';
import '../entities/genre_entity.dart';
import '../entities/hls_playback_entity.dart';
import '../entities/season_entity.dart';

/// Query for `GET /api/content/contents` (matches server Joi schema).
class ListContentsQuery {
  const ListContentsQuery({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.contentType,
    this.status = 'published',
    this.accessType,
    this.categoryId,
    this.genreId,
  });

  final int page;
  final int limit;
  final String? search;
  final String? contentType;
  final String? status;
  final String? accessType;
  final String? categoryId;
  final String? genreId;
}

abstract class ContentCatalogRepository {
  Future<List<CategoryEntity>> listCategories();

  Future<CategoryEntity> getCategoryById(String id);

  Future<List<GenreEntity>> listGenres();

  Future<GenreEntity> getGenreById(String id);

  Future<List<ContentEntity>> listContents(ListContentsQuery query);

  Future<ContentEntity> getContentById(String id);

  Future<TitleDetail> getTitleDetail(String contentId);

  Future<List<SearchResult>> searchContents(ListContentsQuery query);

  /// Recent published titles for chips (no dedicated trending API).
  Future<List<String>> popularTitleSuggestions({int limit = 10});

  /// Signed HLS manifest. Server currently requires admin JWT.
  Future<HlsPlaybackEntity> getHlsPlaybackParams(String videoUploadId);

  // ─── Seasons ────────────────────────────────────────────────────────

  Future<List<SeasonEntity>> listSeasonsForContent(String contentId);

  Future<SeasonEntity> getSeasonById(String seasonId);

  // ─── Episodes ───────────────────────────────────────────────────────

  Future<List<EpisodeEntity>> listEpisodesForContent(String contentId);

  Future<List<EpisodeEntity>> listEpisodesForSeason(String seasonId);

  Future<EpisodeEntity> getEpisodeById(String episodeId);
}
