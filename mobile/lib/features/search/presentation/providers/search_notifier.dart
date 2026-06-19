import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/search_di.dart';
import '../../domain/usecases/search_use_cases.dart';
import 'search_state.dart';

class SearchNotifier extends Notifier<SearchState> {
  late SearchContentUseCase _searchContentUseCase;
  late GetTrendingSearchesUseCase _getTrendingSearchesUseCase;
  late SearchByGenreUseCase _searchByGenreUseCase;
  late BrowsePublishedCatalogUseCase _browsePublishedCatalogUseCase;

  @override
  SearchState build() {
    _searchContentUseCase = ref.read(searchContentUseCaseProvider);
    _getTrendingSearchesUseCase = ref.read(getTrendingSearchesUseCaseProvider);
    _searchByGenreUseCase = ref.read(searchByGenreUseCaseProvider);
    _browsePublishedCatalogUseCase = ref.read(
      browsePublishedCatalogUseCaseProvider,
    );

    Future<void>.microtask(_bootstrap);
    return const SearchState();
  }

  Future<void> _bootstrap() async {
    await _fetchTrendingSearches();
    await _loadBrowse();
  }

  Future<void> _loadBrowse() async {
    try {
      final results = await _browsePublishedCatalogUseCase.call(limit: 24);
      state = state.copyWith(searchResults: results, allResults: results);
    } catch (_) {
      // Leave empty; UI can show empty state.
    }
  }

  Future<void> fetchTrendingSearches() async {
    await _fetchTrendingSearches();
  }

  Future<void> _fetchTrendingSearches() async {
    state = state.copyWith(
      isLoading: true,
      actionType: SearchActionType.fetchingTrending,
      errorMessage: null,
    );

    try {
      final trending = await _getTrendingSearchesUseCase.call();
      state = state.copyWith(
        trendingSearches: trending,
        isLoading: false,
        actionType: SearchActionType.idle,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        actionType: SearchActionType.idle,
      );
    }
  }

  Future<void> searchContent(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
        searchQuery: query,
        searchResults: state.allResults,
        errorMessage: null,
      );
      return;
    }

    state = state.copyWith(
      searchQuery: query,
      isLoading: true,
      actionType: SearchActionType.searching,
      errorMessage: null,
    );

    try {
      final results = await _searchContentUseCase.call(query);
      state = state.copyWith(
        searchResults: results,
        allResults: results,
        isLoading: false,
        actionType: SearchActionType.idle,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        actionType: SearchActionType.idle,
      );
    }
  }

  Future<void> filterByGenreId(String? genreId, {required String label}) async {
    if (genreId == null) {
      state = state.copyWith(
        searchResults: state.allResults,
        selectedGenreLabel: label,
        resetGenreId: true,
      );
      return;
    }

    state = state.copyWith(
      selectedGenreId: genreId,
      selectedGenreLabel: label,
    );

    state = state.copyWith(
      isLoading: true,
      actionType: SearchActionType.filteringByCategory,
      errorMessage: null,
    );

    try {
      final results = await _searchByGenreUseCase.call(
        genreId,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      state = state.copyWith(
        searchResults: results,
        isLoading: false,
        actionType: SearchActionType.idle,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        actionType: SearchActionType.idle,
      );
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      searchResults: state.allResults,
      errorMessage: null,
    );
  }
}
