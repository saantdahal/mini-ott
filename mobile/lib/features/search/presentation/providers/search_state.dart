import '../../domain/entities/search_result.dart';

class SearchState {
  const SearchState({
    this.searchQuery = '',
    this.selectedGenreLabel = 'All',
    this.selectedGenreId,
    this.isLoading = false,
    this.trendingSearches = const [],
    this.searchResults = const [],
    this.allResults = const [],
    this.errorMessage,
    this.actionType = SearchActionType.idle,
  });

  final String searchQuery;
  final String selectedGenreLabel;
  final String? selectedGenreId;
  final bool isLoading;
  final List<String> trendingSearches;
  final List<SearchResult> searchResults;
  final List<SearchResult> allResults;
  final String? errorMessage;
  final SearchActionType actionType;

  SearchState copyWith({
    String? searchQuery,
    String? selectedGenreLabel,
    String? selectedGenreId,
    bool resetGenreId = false,
    bool? isLoading,
    List<String>? trendingSearches,
    List<SearchResult>? searchResults,
    List<SearchResult>? allResults,
    String? errorMessage,
    SearchActionType? actionType,
  }) {
    return SearchState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGenreLabel: selectedGenreLabel ?? this.selectedGenreLabel,
      selectedGenreId: resetGenreId
          ? null
          : (selectedGenreId ?? this.selectedGenreId),
      isLoading: isLoading ?? this.isLoading,
      trendingSearches: trendingSearches ?? this.trendingSearches,
      searchResults: searchResults ?? this.searchResults,
      allResults: allResults ?? this.allResults,
      errorMessage: errorMessage ?? this.errorMessage,
      actionType: actionType ?? this.actionType,
    );
  }

  bool get isTrendingLoading =>
      isLoading && actionType == SearchActionType.fetchingTrending;

  bool get isSearchLoading =>
      isLoading && actionType == SearchActionType.searching;

  bool get isCategoryFilterLoading =>
      isLoading && actionType == SearchActionType.filteringByCategory;

  String? get searchError =>
      actionType == SearchActionType.searching ? errorMessage : null;

  String? get trendingError =>
      actionType == SearchActionType.fetchingTrending ? errorMessage : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchState &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          selectedGenreLabel == other.selectedGenreLabel &&
          selectedGenreId == other.selectedGenreId &&
          isLoading == other.isLoading &&
          trendingSearches == other.trendingSearches &&
          searchResults == other.searchResults &&
          allResults == other.allResults &&
          errorMessage == other.errorMessage &&
          actionType == other.actionType;

  @override
  int get hashCode => Object.hash(
    searchQuery,
    selectedGenreLabel,
    selectedGenreId,
    isLoading,
    trendingSearches,
    searchResults,
    allResults,
    errorMessage,
    actionType,
  );
}

enum SearchActionType { idle, fetchingTrending, searching, filteringByCategory }
