import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../content_catalog/domain/repositories/content_catalog_repository.dart';
import '../data/repositories/search_repository_impl.dart';
import '../domain/repositories/search_repository.dart';
import '../domain/usecases/search_use_cases.dart';

final getIt = GetIt.instance;

class SearchDI {
  static void setup() {
    getIt.registerSingleton<SearchRepository>(
      SearchRepositoryImpl(getIt<ContentCatalogRepository>()),
    );

    getIt.registerSingleton<SearchContentUseCase>(
      SearchContentUseCase(getIt<SearchRepository>()),
    );
    getIt.registerSingleton<GetTrendingSearchesUseCase>(
      GetTrendingSearchesUseCase(getIt<SearchRepository>()),
    );
    getIt.registerSingleton<SearchByGenreUseCase>(
      SearchByGenreUseCase(getIt<SearchRepository>()),
    );
    getIt.registerSingleton<SearchByCategoryUseCase>(
      SearchByCategoryUseCase(getIt<SearchRepository>()),
    );
    getIt.registerSingleton<BrowsePublishedCatalogUseCase>(
      BrowsePublishedCatalogUseCase(getIt<SearchRepository>()),
    );
  }
}

final searchContentUseCaseProvider = Provider<SearchContentUseCase>((ref) {
  return getIt<SearchContentUseCase>();
});

final getTrendingSearchesUseCaseProvider = Provider<GetTrendingSearchesUseCase>(
  (ref) {
    return getIt<GetTrendingSearchesUseCase>();
  },
);

final searchByGenreUseCaseProvider = Provider<SearchByGenreUseCase>((ref) {
  return getIt<SearchByGenreUseCase>();
});

final searchByCategoryUseCaseProvider = Provider<SearchByCategoryUseCase>((
  ref,
) {
  return getIt<SearchByCategoryUseCase>();
});

final browsePublishedCatalogUseCaseProvider =
    Provider<BrowsePublishedCatalogUseCase>((ref) {
      return getIt<BrowsePublishedCatalogUseCase>();
    });
