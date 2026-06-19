import '../../../../app/flavor/app_flavor.dart';
import '../../../content_catalog/domain/repositories/content_catalog_repository.dart';
import '../../domain/entities/content_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../../presentation/models/content_section.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required this.catalogRepository});

  final ContentCatalogRepository catalogRepository;

  /// Returns the appropriate status filter based on flavor.
  /// Dev: null (no filter, show all) | Prod: 'published'
  String? _getStatusFilter() {
    return AppFlavorConfig.isDev ? null : 'published';
  }

  @override
  Future<ContentEntity> getFeaturedContent() async {
    final id = AppFlavorConfig.featuredContentId;
    if (id != null && id.isNotEmpty) {
      return catalogRepository.getContentById(id);
    }
    final statusFilter = _getStatusFilter();
    final list = await catalogRepository.listContents(
      ListContentsQuery(page: 1, limit: 1, status: statusFilter),
    );
    if (list.isEmpty) {
      throw StateError(
        'No ${statusFilter == null ? '' : 'published '}content for featured rail',
      );
    }
    return list.first;
  }

  @override
  Future<List<ContentEntity>> getContinueWatchingContent() async {
    return const [];
  }

  @override
  Future<List<ContentEntity>> getFreeEpisodesContent() async {
    final statusFilter = _getStatusFilter();
    return catalogRepository.listContents(
      ListContentsQuery(
        page: 1,
        limit: 12,
        status: statusFilter,
        accessType: 'free',
      ),
    );
  }

  @override
  Future<List<ContentEntity>> getTrendingContent() async {
    final statusFilter = _getStatusFilter();
    return catalogRepository.listContents(
      ListContentsQuery(
        page: 1,
        limit: 12,
        status: statusFilter,
        contentType: 'movie',
      ),
    );
  }

  @override
  Future<List<ContentEntity>> getNewReleasesContent() async {
    final statusFilter = _getStatusFilter();
    return catalogRepository.listContents(
      ListContentsQuery(page: 1, limit: 12, status: statusFilter),
    );
  }

  /// Maximum titles displayed inline in any single home rail before
  /// the user must tap "See All" to browse the full paginated list.
  static const int _railPreviewLimit = 10;

  /// Page size used while traversing all published content for grouping.
  /// This is the server's `limit` query param — kept at the API max (100)
  /// so we minimize round trips.
  static const int _fetchPageSize = 100;

  /// Hard cap on titles fetched for home grouping. Anything above this is
  /// only reachable through the "See All" paginated screen — protects
  /// against runaway memory if the catalog grows very large.
  static const int _maxItemsForGrouping = 1000;

  Future<List<ContentEntity>> _fetchAllPublished() async {
    final all = <ContentEntity>[];
    final statusFilter = _getStatusFilter();
    var page = 1;
    while (all.length < _maxItemsForGrouping) {
      final batch = await catalogRepository.listContents(
        ListContentsQuery(
          page: page,
          limit: _fetchPageSize,
          status: statusFilter,
        ),
      );
      if (batch.isEmpty) break;
      all.addAll(batch);
      // Partial page → server has nothing more to give.
      if (batch.length < _fetchPageSize) break;
      page += 1;
    }
    return all;
  }

  @override
  Future<List<ContentSection>> getContentGroupedByCategories() async {
    final allContent = await _fetchAllPublished();

    if (allContent.isEmpty) return const [];

    ContentSection capped({
      required String categoryId,
      required String categoryName,
      required int sortOrder,
      String? categoryDescription,
      required List<ContentEntity> source,
    }) {
      final total = source.length;
      final preview = total > _railPreviewLimit
          ? source.sublist(0, _railPreviewLimit)
          : source;
      return ContentSection(
        categoryId: categoryId,
        categoryName: categoryName,
        categoryDescription: categoryDescription,
        sortOrder: sortOrder,
        contents: preview,
        totalCount: total,
        hasMore: total > preview.length,
      );
    }

    final sections = <ContentSection>[];

    // Always lead with "New Releases" (server already orders by created_at DESC).
    sections.add(
      capped(
        categoryId: virtualLatestId,
        categoryName: 'New Releases',
        categoryDescription: 'Latest published titles on the platform',
        sortOrder: -1,
        source: allContent,
      ),
    );

    // Group by category (preserves API sort_order). Each title can appear in
    // multiple category rails — that's the desired browsing model.
    final byCategoryItems = <String, _CategoryBucket>{};
    final uncategorized = <ContentEntity>[];

    for (final c in allContent) {
      if (c.categories.isEmpty) {
        uncategorized.add(c);
        continue;
      }
      for (final category in c.categories) {
        final key = category.categoryId;
        final existing = byCategoryItems[key];
        if (existing != null) {
          existing.items.add(c);
        } else {
          byCategoryItems[key] = _CategoryBucket(
            id: key,
            name: category.name,
            description: category.description,
            sortOrder: category.sortOrder ?? 999,
            items: [c],
          );
        }
      }
    }

    final categorySections =
        (byCategoryItems.values.toList()
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
            .map(
              (b) => capped(
                categoryId: b.id,
                categoryName: b.name,
                categoryDescription: b.description,
                sortOrder: b.sortOrder,
                source: b.items,
              ),
            )
            .toList();
    sections.addAll(categorySections);

    if (uncategorized.isNotEmpty) {
      sections.add(
        capped(
          categoryId: virtualUncategorizedId,
          categoryName: 'More Titles',
          categoryDescription: 'Other titles you may enjoy',
          sortOrder: 9999,
          source: uncategorized,
        ),
      );
    }

    return sections;
  }
}

class _CategoryBucket {
  _CategoryBucket({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.items,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final int sortOrder;
  final List<ContentEntity> items;
}

/// Identifier used by the "New Releases" virtual rail (no server filter).
const String virtualLatestId = '__new_releases';

/// Identifier used by the "More Titles" rail of uncategorized content.
/// The browse screen cannot paginate this bucket because the server has no
/// "no category" filter — the home rail is the full set already.
const String virtualUncategorizedId = '__all_titles';

/// True if the section is virtual (not a real server category).
bool isVirtualCategoryId(String id) =>
    id == virtualLatestId || id == virtualUncategorizedId;
