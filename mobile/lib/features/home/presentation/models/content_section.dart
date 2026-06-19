import '../../domain/entities/content_entity.dart';

class ContentSection {
  final String categoryId;
  final String categoryName;
  final String? categoryDescription;
  final int sortOrder;
  final List<ContentEntity> contents;

  /// Total titles available for this section across pages on the server.
  /// May exceed `contents.length` when the home rail is capped for preview.
  final int totalCount;

  /// True when there are more items than what's shown in the rail —
  /// the home screen uses this to decide whether to render "See All".
  final bool hasMore;

  ContentSection({
    required this.categoryId,
    required this.categoryName,
    this.categoryDescription,
    required this.sortOrder,
    required List<ContentEntity> contents,
    int? totalCount,
    bool? hasMore,
  })  : contents = List.from(contents), // mutable copy
        totalCount = totalCount ?? contents.length,
        hasMore = hasMore ?? false;
}
