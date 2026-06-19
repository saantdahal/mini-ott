import '../entities/search_result.dart';

abstract class SearchRepository {
  Future<List<SearchResult>> searchContent(String query);

  Future<List<String>> getTrendingSearches();

  /// Server filters by `genre_id` (UUID).
  Future<List<SearchResult>> filterByGenreId(
    String? genreId, {
    String? searchQuery,
  });

  /// Server filters by `category_id` (UUID) + optional title search.
  Future<List<SearchResult>> searchByCategory(
    String categoryId,
    String query,
  );

  /// Default grid when search box is empty.
  Future<List<SearchResult>> browsePublished({int limit = 24});
}
