import 'package:dio/dio.dart';

import '../../../../core/network/api/api_client.dart';
import '../../../content_details/domain/entities/title_detail.dart';
import '../../../home/domain/entities/content_entity.dart';
import '../../../search/domain/entities/search_result.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/episode_entity.dart';
import '../../domain/entities/genre_entity.dart';
import '../../domain/entities/hls_playback_entity.dart';
import '../../domain/entities/season_entity.dart';
import '../../domain/repositories/content_catalog_repository.dart';
import '../mappers/catalog_content_mapper.dart';

class ContentCatalogRepositoryImpl implements ContentCatalogRepository {
  ContentCatalogRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<CategoryEntity>> listCategories() async {
    final res = await _api.listCategories();
    final list = res.data.result ?? const [];
    return list.map(CatalogContentMapper.toCategoryEntity).toList();
  }

  @override
  Future<List<GenreEntity>> listGenres() async {
    final res = await _api.listGenres();
    final list = res.data.result ?? const [];
    return list.map(CatalogContentMapper.toGenreEntity).toList();
  }

  @override
  Future<List<ContentEntity>> listContents(ListContentsQuery query) async {
    final res = await _api.listContents(
      page: query.page,
      limit: query.limit,
      search: query.search,
      contentType: query.contentType,
      status: query.status,
      accessType: query.accessType,
      categoryId: query.categoryId,
      genreId: query.genreId,
    );
    final items = res.data.result?.items ?? const [];
    return items.map(CatalogContentMapper.toContentEntity).toList();
  }

  @override
  Future<ContentEntity> getContentById(String id) async {
    final res = await _api.getContent(id);
    final dto = res.data.result;
    if (dto == null) {
      throw StateError(res.data.message);
    }
    return CatalogContentMapper.toContentEntity(dto);
  }

  @override
  Future<TitleDetail> getTitleDetail(String contentId) async {
    final res = await _api.getContent(contentId);
    final dto = res.data.result;
    if (dto == null) {
      throw StateError(res.data.message);
    }
    return CatalogContentMapper.toTitleDetail(dto);
  }

  @override
  Future<List<SearchResult>> searchContents(ListContentsQuery query) async {
    final res = await _api.listContents(
      page: query.page,
      limit: query.limit,
      search: query.search,
      contentType: query.contentType,
      status: query.status,
      accessType: query.accessType,
      categoryId: query.categoryId,
      genreId: query.genreId,
    );
    final items = res.data.result?.items ?? const [];
    return items.map(CatalogContentMapper.toSearchResult).toList();
  }

  @override
  Future<List<String>> popularTitleSuggestions({int limit = 10}) async {
    final res = await _api.listContents(
      page: 1,
      limit: limit,
      status: 'published',
    );
    final items = res.data.result?.items ?? const [];
    return items.map((e) => e.title).toList();
  }

  @override
  Future<HlsPlaybackEntity> getHlsPlaybackParams(String videoUploadId) async {
    try {
      final res = await _api.getHlsPlaybackParams(videoUploadId);
      if (!res.data.success || res.data.data == null) {
        throw StateError(res.data.message);
      }
      return CatalogContentMapper.toHlsEntity(res.data.data);
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : e.message;
      throw StateError(msg ?? 'Playback request failed');
    }
  }

  // ─── Category / Genre by id ──────────────────────────────────────────

  @override
  Future<CategoryEntity> getCategoryById(String id) async {
    final res = await _api.getCategory(id);
    final dto = res.data.result;
    if (dto == null) {
      throw StateError(res.data.message);
    }
    return CatalogContentMapper.toCategoryEntity(dto);
  }

  @override
  Future<GenreEntity> getGenreById(String id) async {
    final res = await _api.getGenre(id);
    final dto = res.data.result;
    if (dto == null) {
      throw StateError(res.data.message);
    }
    return CatalogContentMapper.toGenreEntity(dto);
  }

  // ─── Seasons ─────────────────────────────────────────────────────────

  @override
  Future<List<SeasonEntity>> listSeasonsForContent(String contentId) async {
    final res = await _api.listSeasonsForContent(contentId);
    final list = res.data.result ?? const [];
    return list.map(CatalogContentMapper.toSeasonEntity).toList();
  }

  @override
  Future<SeasonEntity> getSeasonById(String seasonId) async {
    final res = await _api.getSeason(seasonId);
    final dto = res.data.result;
    if (dto == null) {
      throw StateError(res.data.message);
    }
    return CatalogContentMapper.toSeasonEntity(dto);
  }

  // ─── Episodes ────────────────────────────────────────────────────────

  @override
  Future<List<EpisodeEntity>> listEpisodesForContent(String contentId) async {
    final res = await _api.listEpisodesForContent(contentId);
    final list = res.data.result ?? const [];
    return list.map(CatalogContentMapper.toEpisodeEntity).toList();
  }

  @override
  Future<List<EpisodeEntity>> listEpisodesForSeason(String seasonId) async {
    final res = await _api.listEpisodesForSeason(seasonId);
    final list = res.data.result ?? const [];
    return list.map(CatalogContentMapper.toEpisodeEntity).toList();
  }

  @override
  Future<EpisodeEntity> getEpisodeById(String episodeId) async {
    final res = await _api.getEpisode(episodeId);
    final dto = res.data.result;
    if (dto == null) {
      throw StateError(res.data.message);
    }
    return CatalogContentMapper.toEpisodeEntity(dto);
  }
}
