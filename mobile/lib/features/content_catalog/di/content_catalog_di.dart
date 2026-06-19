import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/di.dart';
import '../../content_details/domain/entities/title_detail.dart';
import '../domain/entities/category_entity.dart';
import '../domain/entities/episode_entity.dart';
import '../domain/entities/genre_entity.dart';
import '../domain/entities/season_entity.dart';
import '../domain/repositories/content_catalog_repository.dart';
import '../domain/usecases/get_hls_playback_usecase.dart';

final contentCatalogRepositoryProvider = Provider<ContentCatalogRepository>(
  (ref) => getIt<ContentCatalogRepository>(),
);

// ─── Categories / Genres ──────────────────────────────────────────────

final categoriesListProvider =
    FutureProvider.autoDispose<List<CategoryEntity>>((ref) {
  return ref.watch(contentCatalogRepositoryProvider).listCategories();
});

final categoryByIdProvider = FutureProvider.autoDispose
    .family<CategoryEntity, String>((ref, id) {
  return ref.watch(contentCatalogRepositoryProvider).getCategoryById(id);
});

final genresListProvider = FutureProvider<List<GenreEntity>>((ref) async {
  return ref.watch(contentCatalogRepositoryProvider).listGenres();
});

final genreByIdProvider =
    FutureProvider.autoDispose.family<GenreEntity, String>((ref, id) {
  return ref.watch(contentCatalogRepositoryProvider).getGenreById(id);
});

// ─── Title detail ─────────────────────────────────────────────────────

final titleDetailProvider =
    FutureProvider.autoDispose.family<TitleDetail, String>((ref, contentId) {
  return ref.watch(contentCatalogRepositoryProvider).getTitleDetail(contentId);
});

// ─── Seasons ──────────────────────────────────────────────────────────

/// All seasons for a given content (server orders by `season_number ASC`).
final seasonsForContentProvider = FutureProvider.autoDispose
    .family<List<SeasonEntity>, String>((ref, contentId) {
  return ref
      .watch(contentCatalogRepositoryProvider)
      .listSeasonsForContent(contentId);
});

/// A single season — useful when navigating directly to a season screen.
final seasonByIdProvider =
    FutureProvider.autoDispose.family<SeasonEntity, String>((ref, seasonId) {
  return ref.watch(contentCatalogRepositoryProvider).getSeasonById(seasonId);
});

// ─── Episodes ─────────────────────────────────────────────────────────

/// All episodes across all seasons for a content. Prefer
/// [episodesForSeasonProvider] when a season is in scope, since payloads are
/// smaller.
final episodesForContentProvider = FutureProvider.autoDispose
    .family<List<EpisodeEntity>, String>((ref, contentId) {
  return ref
      .watch(contentCatalogRepositoryProvider)
      .listEpisodesForContent(contentId);
});

/// Lazy-loaded episodes for a specific season. Backs season-tab UIs that
/// fetch on selection rather than upfront.
final episodesForSeasonProvider = FutureProvider.autoDispose
    .family<List<EpisodeEntity>, String>((ref, seasonId) {
  return ref
      .watch(contentCatalogRepositoryProvider)
      .listEpisodesForSeason(seasonId);
});

final episodeByIdProvider =
    FutureProvider.autoDispose.family<EpisodeEntity, String>((ref, episodeId) {
  return ref.watch(contentCatalogRepositoryProvider).getEpisodeById(episodeId);
});

// ─── Playback ─────────────────────────────────────────────────────────

final getHlsPlaybackUseCaseProvider = Provider<GetHlsPlaybackUseCase>(
  (ref) => GetHlsPlaybackUseCase(ref.watch(contentCatalogRepositoryProvider)),
);
