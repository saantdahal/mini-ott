import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_continue_watching_usecase.dart';
import '../domain/usecases/get_featured_content_usecase.dart';
import '../domain/usecases/get_free_episodes_usecase.dart';
import '../domain/usecases/get_new_releases_usecase.dart';
import '../domain/usecases/get_trending_content_usecase.dart';
import '../../content_catalog/di/content_catalog_di.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(
    catalogRepository: ref.watch(contentCatalogRepositoryProvider),
  );
});

final getFeaturedContentUseCaseProvider = Provider<GetFeaturedContentUseCase>((
  ref,
) {
  return GetFeaturedContentUseCase(ref.watch(homeRepositoryProvider));
});

final getContinueWatchingUseCaseProvider = Provider<GetContinueWatchingUseCase>(
  (ref) {
    return GetContinueWatchingUseCase(ref.watch(homeRepositoryProvider));
  },
);

final getFreeEpisodesUseCaseProvider = Provider<GetFreeEpisodesUseCase>((ref) {
  return GetFreeEpisodesUseCase(ref.watch(homeRepositoryProvider));
});

final getTrendingContentUseCaseProvider = Provider<GetTrendingContentUseCase>((
  ref,
) {
  return GetTrendingContentUseCase(ref.watch(homeRepositoryProvider));
});

final getNewReleasesUseCaseProvider = Provider<GetNewReleasesUseCase>((ref) {
  return GetNewReleasesUseCase(ref.watch(homeRepositoryProvider));
});
