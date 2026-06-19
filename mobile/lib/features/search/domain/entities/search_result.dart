class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.contentType,
    required this.genres,
    required this.rating,
    required this.duration,
    required this.isTrendingTag,
    required this.isPremiumTag,
    this.overlayLabel,
    this.showYellowCorner = false,
  });

  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String contentType;
  final List<String> genres;
  final double rating;
  final String duration;
  final bool isTrendingTag;
  final bool isPremiumTag;
  final String? overlayLabel;
  final bool showYellowCorner;

  SearchResult copyWith({
    String? id,
    String? title,
    String? description,
    String? posterUrl,
    String? contentType,
    List<String>? genres,
    double? rating,
    String? duration,
    bool? isTrendingTag,
    bool? isPremiumTag,
    String? overlayLabel,
    bool? showYellowCorner,
  }) {
    return SearchResult(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      contentType: contentType ?? this.contentType,
      genres: genres ?? this.genres,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
      isTrendingTag: isTrendingTag ?? this.isTrendingTag,
      isPremiumTag: isPremiumTag ?? this.isPremiumTag,
      overlayLabel: overlayLabel ?? this.overlayLabel,
      showYellowCorner: showYellowCorner ?? this.showYellowCorner,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          posterUrl == other.posterUrl &&
          contentType == other.contentType &&
          genres == other.genres &&
          rating == other.rating &&
          duration == other.duration &&
          isTrendingTag == other.isTrendingTag &&
          isPremiumTag == other.isPremiumTag &&
          overlayLabel == other.overlayLabel &&
          showYellowCorner == other.showYellowCorner;

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    description,
    posterUrl,
    contentType,
    genres,
    rating,
    duration,
    isTrendingTag,
    isPremiumTag,
    overlayLabel,
    showYellowCorner,
  ]);

  @override
  String toString() {
    return 'SearchResult(id: $id, title: $title, contentType: $contentType, genres: $genres)';
  }
}
