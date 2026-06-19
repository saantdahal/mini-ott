class ContentEntity {
  const ContentEntity({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl = '',
    this.posterUrl = '',
    this.genres = const [],
    this.categories = const [],
    this.rating = 0.0,
    this.accessType = '',
    this.isWatching = false,
    this.watchingProgress = '',
    this.contentType = '',
    this.ageRating = '',
    this.cardSubtitle,
    this.freeBannerText,
    this.episodeChip,
    this.showPremiumLock = false,
  });

  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String posterUrl;
  final List<String> genres;
  final List<ContentCategory> categories;
  final double rating;
  final String accessType;
  final bool isWatching;
  final String watchingProgress;
  final String contentType;
  final String ageRating;
  final String? cardSubtitle;
  final String? freeBannerText;
  final String? episodeChip;
  final bool showPremiumLock;

  ContentEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? posterUrl,
    List<String>? genres,
    List<ContentCategory>? categories,
    double? rating,
    String? accessType,
    bool? isWatching,
    String? watchingProgress,
    String? contentType,
    String? ageRating,
    String? cardSubtitle,
    String? freeBannerText,
    String? episodeChip,
    bool? showPremiumLock,
  }) {
    return ContentEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      posterUrl: posterUrl ?? this.posterUrl,
      genres: genres ?? this.genres,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      accessType: accessType ?? this.accessType,
      isWatching: isWatching ?? this.isWatching,
      watchingProgress: watchingProgress ?? this.watchingProgress,
      contentType: contentType ?? this.contentType,
      ageRating: ageRating ?? this.ageRating,
      cardSubtitle: cardSubtitle ?? this.cardSubtitle,
      freeBannerText: freeBannerText ?? this.freeBannerText,
      episodeChip: episodeChip ?? this.episodeChip,
      showPremiumLock: showPremiumLock ?? this.showPremiumLock,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          thumbnailUrl == other.thumbnailUrl &&
          posterUrl == other.posterUrl &&
          genres == other.genres &&
          categories == other.categories &&
          rating == other.rating &&
          accessType == other.accessType &&
          isWatching == other.isWatching &&
          watchingProgress == other.watchingProgress &&
          contentType == other.contentType &&
          ageRating == other.ageRating &&
          cardSubtitle == other.cardSubtitle &&
          freeBannerText == other.freeBannerText &&
          episodeChip == other.episodeChip &&
          showPremiumLock == other.showPremiumLock;

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    description,
    thumbnailUrl,
    posterUrl,
    genres,
    categories,
    rating,
    accessType,
    isWatching,
    watchingProgress,
    contentType,
    ageRating,
    cardSubtitle,
    freeBannerText,
    episodeChip,
    showPremiumLock,
  ]);

  @override
  String toString() {
    return 'ContentEntity(id: $id, title: $title, description: $description, '
        'thumbnailUrl: $thumbnailUrl, posterUrl: $posterUrl, genres: $genres, '
        'categories: $categories, '
        'rating: $rating, accessType: $accessType, isWatching: $isWatching, '
        'watchingProgress: $watchingProgress, contentType: $contentType, '
        'ageRating: $ageRating, cardSubtitle: $cardSubtitle, '
        'freeBannerText: $freeBannerText, episodeChip: $episodeChip, '
        'showPremiumLock: $showPremiumLock)';
  }
}

class ContentCategory {
  const ContentCategory({
    required this.categoryId,
    required this.name,
    this.description,
    this.sortOrder,
  });

  final String categoryId;
  final String name;
  final String? description;
  final int? sortOrder;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentCategory &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          name == other.name;

  @override
  int get hashCode => Object.hash(categoryId, name);

  @override
  String toString() =>
      'ContentCategory(categoryId: $categoryId, name: $name, sortOrder: $sortOrder)';
}
