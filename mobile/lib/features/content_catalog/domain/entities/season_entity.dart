class SeasonEntity {
  const SeasonEntity({
    required this.id,
    required this.contentId,
    required this.seasonNumber,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.releaseDate,
    this.status,
  });

  final String id;
  final String contentId;
  final int seasonNumber;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? releaseDate;
  final String? status;

  /// Display label — `title` when set, otherwise `Season N`.
  String get displayTitle {
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    return 'Season $seasonNumber';
  }
}
