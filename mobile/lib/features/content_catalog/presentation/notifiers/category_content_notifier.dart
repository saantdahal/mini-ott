import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_error_mapper.dart';
import '../../../home/data/repositories/home_repository_impl.dart'
    show virtualUncategorizedId, isVirtualCategoryId;
import '../../../home/domain/entities/content_entity.dart';
import '../../di/content_catalog_di.dart';
import '../../domain/repositories/content_catalog_repository.dart';

/// Args for [categoryContentNotifierProvider]. Used as the family key, so two
/// distinct categories produce distinct notifier instances.
class CategoryContentArgs {
  const CategoryContentArgs({required this.categoryId, required this.name});

  final String categoryId;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryContentArgs &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          name == other.name;

  @override
  int get hashCode => Object.hash(categoryId, name);
}

class CategoryContentState {
  const CategoryContentState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<ContentEntity> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  CategoryContentState copyWith({
    List<ContentEntity>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return CategoryContentState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();
}

class CategoryContentNotifier extends Notifier<CategoryContentState> {
  CategoryContentNotifier(this.args);

  /// Family argument injected via the family provider's constructor closure.
  final CategoryContentArgs args;

  /// Server-side page size for the lazy-loaded grid.
  static const int pageSize = 20;

  @override
  CategoryContentState build() => const CategoryContentState();

  ContentCatalogRepository get _repo =>
      ref.read(contentCatalogRepositoryProvider);

  String? get _serverCategoryId =>
      isVirtualCategoryId(args.categoryId) ? null : args.categoryId;

  Future<void> refresh() async {
    state = const CategoryContentState(isLoading: true);
    try {
      final firstPage = await _fetchPage(1);
      state = CategoryContentState(
        items: firstPage,
        page: 1,
        hasMore: firstPage.length == pageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapErrorToUserMessage(e),
      );
    }
  }

  Future<void> loadFirstPageIfNeeded() async {
    if (state.isLoading || state.isLoadingMore) return;
    if (state.items.isNotEmpty) return;
    await refresh();
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore) return;
    if (!state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    try {
      final next = await _fetchPage(state.page + 1);
      state = state.copyWith(
        items: [...state.items, ...next],
        page: state.page + 1,
        hasMore: next.length == pageSize,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: mapErrorToUserMessage(e),
      );
    }
  }

  Future<List<ContentEntity>> _fetchPage(int page) {
    if (args.categoryId == virtualUncategorizedId && page > 1) {
      // Server has no "no category" filter — uncategorized contents only
      // exist as a synthesized home rail; never paginate beyond page 1.
      return Future.value(const []);
    }
    return _repo.listContents(
      ListContentsQuery(
        page: page,
        limit: pageSize,
        status: 'published',
        categoryId: _serverCategoryId,
      ),
    );
  }
}

final categoryContentNotifierProvider = NotifierProvider.autoDispose
    .family<CategoryContentNotifier, CategoryContentState, CategoryContentArgs>(
  CategoryContentNotifier.new,
);
