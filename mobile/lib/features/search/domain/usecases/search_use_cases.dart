import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchContentUseCase {
  SearchContentUseCase(this.repository);

  final SearchRepository repository;

  Future<List<SearchResult>> call(String query) =>
      repository.searchContent(query);
}

class GetTrendingSearchesUseCase {
  GetTrendingSearchesUseCase(this.repository);

  final SearchRepository repository;

  Future<List<String>> call() => repository.getTrendingSearches();
}

class SearchByGenreUseCase {
  SearchByGenreUseCase(this.repository);

  final SearchRepository repository;

  Future<List<SearchResult>> call(
    String? genreId, {
    String? searchQuery,
  }) => repository.filterByGenreId(genreId, searchQuery: searchQuery);
}

class SearchByCategoryUseCase {
  SearchByCategoryUseCase(this.repository);

  final SearchRepository repository;

  Future<List<SearchResult>> call({
    required String categoryId,
    required String query,
  }) => repository.searchByCategory(categoryId, query);
}

class BrowsePublishedCatalogUseCase {
  BrowsePublishedCatalogUseCase(this.repository);

  final SearchRepository repository;

  Future<List<SearchResult>> call({int limit = 24}) =>
      repository.browsePublished(limit: limit);
}
