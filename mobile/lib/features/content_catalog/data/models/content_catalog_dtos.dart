import 'package:json_annotation/json_annotation.dart';

part 'content_catalog_dtos.g.dart';

// ─── Categories / Genres ─────────────────────────────────────────────

@JsonSerializable()
class CategoryDto {
  const CategoryDto({
    required this.categoryId,
    required this.name,
    this.slug,
    this.description,
    this.sortOrder,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: 'category_id')
  final String categoryId;
  final String name;
  final String? slug;
  final String? description;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  final String? status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDtoToJson(this);
}

@JsonSerializable()
class GenreDto {
  const GenreDto({
    required this.genreId,
    required this.name,
    this.slug,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: 'genre_id')
  final String genreId;
  final String name;
  final String? slug;
  final String? description;
  final String? status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  factory GenreDto.fromJson(Map<String, dynamic> json) =>
      _$GenreDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GenreDtoToJson(this);
}

@JsonSerializable()
class CategoriesListEnvelope {
  const CategoriesListEnvelope({
    required this.success,
    required this.message,
    this.result,
  });

  final bool success;
  final String message;
  final List<CategoryDto>? result;

  factory CategoriesListEnvelope.fromJson(Map<String, dynamic> json) =>
      _$CategoriesListEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$CategoriesListEnvelopeToJson(this);
}

@JsonSerializable()
class GenresListEnvelope {
  const GenresListEnvelope({
    required this.success,
    required this.message,
    this.result,
  });

  final bool success;
  final String message;
  final List<GenreDto>? result;

  factory GenresListEnvelope.fromJson(Map<String, dynamic> json) =>
      _$GenresListEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$GenresListEnvelopeToJson(this);
}

@JsonSerializable()
class CategorySingleEnvelope {
  const CategorySingleEnvelope({
    required this.success,
    required this.message,
    this.result,
  });

  final bool success;
  final String message;
  final CategoryDto? result;

  factory CategorySingleEnvelope.fromJson(Map<String, dynamic> json) =>
      _$CategorySingleEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$CategorySingleEnvelopeToJson(this);
}

@JsonSerializable()
class GenreSingleEnvelope {
  const GenreSingleEnvelope({
    required this.success,
    required this.message,
    this.result,
  });

  final bool success;
  final String message;
  final GenreDto? result;

  factory GenreSingleEnvelope.fromJson(Map<String, dynamic> json) =>
      _$GenreSingleEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$GenreSingleEnvelopeToJson(this);
}

// ─── Pagination + list contents ───────────────────────────────────────

@JsonSerializable()
class PaginationDto {
  const PaginationDto({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  @JsonKey(name: 'total_pages')
  final int totalPages;

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ContentListResultDto {
  const ContentListResultDto({required this.items, required this.pagination});

  final List<ContentApiDto> items;
  final PaginationDto pagination;

  factory ContentListResultDto.fromJson(Map<String, dynamic> json) =>
      _$ContentListResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ContentListResultDtoToJson(this);
}

@JsonSerializable()
class ContentListEnvelope {
  const ContentListEnvelope({
    required this.success,
    required this.message,
    this.result,
  });

  final bool success;
  final String message;
  final ContentListResultDto? result;

  factory ContentListEnvelope.fromJson(Map<String, dynamic> json) =>
      _$ContentListEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$ContentListEnvelopeToJson(this);
}

// ─── Season / Episode ────────────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class SeasonApiDto {
  const SeasonApiDto({
    required this.seasonId,
    this.contentId,
    this.seasonNumber,
    this.title,
    this.description,
    this.thumbnailKey,
    this.status,
    this.releaseDate,
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: 'season_id')
  final String seasonId;
  @JsonKey(name: 'content_id')
  final String? contentId;
  @JsonKey(name: 'season_number')
  final int? seasonNumber;
  final String? title;
  final String? description;
  @JsonKey(name: 'thumbnail_key')
  final String? thumbnailKey;
  final String? status;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  factory SeasonApiDto.fromJson(Map<String, dynamic> json) =>
      _$SeasonApiDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SeasonApiDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EpisodeApiDto {
  const EpisodeApiDto({
    required this.episodeId,
    this.contentId,
    this.seasonId,
    this.episodeNumber,
    this.title,
    this.slug,
    this.description,
    this.shortDescription,
    this.thumbnailKey,
    this.bannerKey,
    this.videoKey,
    this.streamManifestKey,
    this.videoUploadId,
    this.durationSeconds,
    this.accessType,
    this.requiredCoins,
    this.status,
    this.releaseDate,
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: 'episode_id')
  final String episodeId;
  @JsonKey(name: 'content_id')
  final String? contentId;
  @JsonKey(name: 'season_id')
  final String? seasonId;
  @JsonKey(name: 'episode_number')
  final int? episodeNumber;
  final String? title;
  final String? slug;
  final String? description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'thumbnail_key')
  final String? thumbnailKey;
  @JsonKey(name: 'banner_key')
  final String? bannerKey;
  @JsonKey(name: 'video_key')
  final String? videoKey;
  @JsonKey(name: 'stream_manifest_key')
  final String? streamManifestKey;
  @JsonKey(name: 'video_upload_id')
  final String? videoUploadId;
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @JsonKey(name: 'access_type')
  final String? accessType;
  @JsonKey(name: 'required_coins')
  final int? requiredCoins;
  final String? status;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  factory EpisodeApiDto.fromJson(Map<String, dynamic> json) =>
      _$EpisodeApiDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodeApiDtoToJson(this);
}

@JsonSerializable()
class SeasonsListEnvelope {
  const SeasonsListEnvelope({
    required this.success,
    required this.message,
    this.result,
  });

  final bool success;
  final String message;
  final List<SeasonApiDto>? result;

  factory SeasonsListEnvelope.fromJson(Map<String, dynamic> json) =>
      _$SeasonsListEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$SeasonsListEnvelopeToJson(this);
}

@JsonSerializable()
class EpisodesListEnvelope {
  const EpisodesListEnvelope({
    required this.success,
    required this.message,
    this.result,
  });

  final bool success;
  final String message;
  final List<EpisodeApiDto>? result;

  factory EpisodesListEnvelope.fromJson(Map<String, dynamic> json) =>
      _$EpisodesListEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodesListEnvelopeToJson(this);
}

@JsonSerializable()
class SeasonSingleEnvelope {
  const SeasonSingleEnvelope({
    required this.success,
    required this.message,
    this.result,
  });

  final bool success;
  final String message;
  final SeasonApiDto? result;

  factory SeasonSingleEnvelope.fromJson(Map<String, dynamic> json) =>
      _$SeasonSingleEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$SeasonSingleEnvelopeToJson(this);
}

@JsonSerializable()
class EpisodeSingleEnvelope {
  const EpisodeSingleEnvelope({
    required this.success,
    required this.message,
    this.result,
  });

  final bool success;
  final String message;
  final EpisodeApiDto? result;

  factory EpisodeSingleEnvelope.fromJson(Map<String, dynamic> json) =>
      _$EpisodeSingleEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodeSingleEnvelopeToJson(this);
}

// ─── Content (list + detail) ─────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class ContentApiDto {
  const ContentApiDto({
    required this.contentId,
    required this.title,
    this.slug,
    this.description,
    this.shortDescription,
    this.contentType,
    this.isSeries,
    this.language,
    this.country,
    this.ageRating,
    this.releaseDate,
    this.durationSeconds,
    this.totalSeasons,
    this.totalEpisodes,
    this.thumbnailKey,
    this.posterKey,
    this.bannerKey,
    this.trailerKey,
    this.streamManifestKey,
    this.videoUploadId,
    this.accessType,
    this.requiredCoins,
    this.status,
    this.publishedAt,
    this.categories,
    this.genres,
    this.seasons,
    this.episodes,
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: 'content_id')
  final String contentId;
  final String title;
  final String? slug;
  final String? description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'content_type')
  final String? contentType;
  @JsonKey(name: 'is_series')
  final bool? isSeries;
  final String? language;
  final String? country;
  @JsonKey(name: 'age_rating')
  final String? ageRating;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @JsonKey(name: 'total_seasons')
  final int? totalSeasons;
  @JsonKey(name: 'total_episodes')
  final int? totalEpisodes;
  @JsonKey(name: 'thumbnail_key')
  final String? thumbnailKey;
  @JsonKey(name: 'poster_key')
  final String? posterKey;
  @JsonKey(name: 'banner_key')
  final String? bannerKey;
  @JsonKey(name: 'trailer_key')
  final String? trailerKey;
  @JsonKey(name: 'stream_manifest_key')
  final String? streamManifestKey;
  @JsonKey(name: 'video_upload_id')
  final String? videoUploadId;
  @JsonKey(name: 'access_type')
  final String? accessType;
  @JsonKey(name: 'required_coins')
  final int? requiredCoins;
  final String? status;
  @JsonKey(name: 'published_at')
  final String? publishedAt;
  final List<CategoryDto>? categories;
  final List<GenreDto>? genres;
  final List<SeasonApiDto>? seasons;
  final List<EpisodeApiDto>? episodes;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  factory ContentApiDto.fromJson(Map<String, dynamic> json) =>
      _$ContentApiDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ContentApiDtoToJson(this);
}

@JsonSerializable()
class ContentSingleEnvelope {
  const ContentSingleEnvelope({
    required this.success,
    required this.message,
    this.result,
  });

  final bool success;
  final String message;
  final ContentApiDto? result;

  factory ContentSingleEnvelope.fromJson(Map<String, dynamic> json) =>
      _$ContentSingleEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$ContentSingleEnvelopeToJson(this);
}

// ─── HLS stream (server uses `data`, not `result`) ───────────────────

@JsonSerializable()
class HlsPlaybackDataDto {
  const HlsPlaybackDataDto({
    this.manifestUrl,
    this.queryParams,
    this.baseUrl,
    this.expiresIn,
    this.phase,
  });

  @JsonKey(name: 'manifest_url')
  final String? manifestUrl;
  @JsonKey(name: 'query_params')
  final String? queryParams;
  @JsonKey(name: 'base_url')
  final String? baseUrl;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  final String? phase;

  factory HlsPlaybackDataDto.fromJson(Map<String, dynamic> json) =>
      _$HlsPlaybackDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HlsPlaybackDataDtoToJson(this);
}

@JsonSerializable()
class HlsPlaybackEnvelope {
  const HlsPlaybackEnvelope({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final HlsPlaybackDataDto? data;

  factory HlsPlaybackEnvelope.fromJson(Map<String, dynamic> json) =>
      _$HlsPlaybackEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$HlsPlaybackEnvelopeToJson(this);
}
