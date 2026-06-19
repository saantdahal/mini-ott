import '../../../content_catalog/domain/repositories/content_catalog_repository.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._catalog);

  final ContentCatalogRepository _catalog;

  @override
  Future<List<SearchResult>> searchContent(String query) async {
    if (query.trim().isEmpty) {
      return browsePublished();
    }
    return _catalog.searchContents(
      ListContentsQuery(
        page: 1,
        limit: 40,
        search: query.trim(),
        status: 'published',
      ),
    );
  }

  @override
  Future<List<String>> getTrendingSearches() async {
    return _catalog.popularTitleSuggestions(limit: 12);
  }

  @override
  Future<List<SearchResult>> filterByGenreId(
    String? genreId, {
    String? searchQuery,
  }) async {
    final q = searchQuery?.trim();
    return _catalog.searchContents(
      ListContentsQuery(
        page: 1,
        limit: 40,
        status: 'published',
        genreId: genreId,
        search: (q == null || q.isEmpty) ? null : q,
      ),
    );
  }

  @override
  Future<List<SearchResult>> searchByCategory(
    String categoryId,
    String query,
  ) async {
    return _catalog.searchContents(
      ListContentsQuery(
        page: 1,
        limit: 40,
        status: 'published',
        categoryId: categoryId,
        search: query.trim().isEmpty ? null : query.trim(),
      ),
    );
  }

  @override
  Future<List<SearchResult>> browsePublished({int limit = 24}) async {
    return _catalog.searchContents(
      ListContentsQuery(page: 1, limit: limit, status: 'published'),
    );
  }
}
