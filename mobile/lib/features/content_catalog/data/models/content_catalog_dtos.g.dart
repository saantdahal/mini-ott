// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_catalog_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryDto _$CategoryDtoFromJson(Map<String, dynamic> json) => CategoryDto(
  categoryId: json['category_id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String?,
  description: json['description'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  status: json['status'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$CategoryDtoToJson(CategoryDto instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'sort_order': instance.sortOrder,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

GenreDto _$GenreDtoFromJson(Map<String, dynamic> json) => GenreDto(
  genreId: json['genre_id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String?,
  description: json['description'] as String?,
  status: json['status'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$GenreDtoToJson(GenreDto instance) => <String, dynamic>{
  'genre_id': instance.genreId,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'status': instance.status,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

CategoriesListEnvelope _$CategoriesListEnvelopeFromJson(
  Map<String, dynamic> json,
) => CategoriesListEnvelope(
  success: json['success'] as bool,
  message: json['message'] as String,
  result: (json['result'] as List<dynamic>?)
      ?.map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoriesListEnvelopeToJson(
  CategoriesListEnvelope instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'result': instance.result,
};

GenresListEnvelope _$GenresListEnvelopeFromJson(Map<String, dynamic> json) =>
    GenresListEnvelope(
      success: json['success'] as bool,
      message: json['message'] as String,
      result: (json['result'] as List<dynamic>?)
          ?.map((e) => GenreDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GenresListEnvelopeToJson(GenresListEnvelope instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'result': instance.result,
    };

CategorySingleEnvelope _$CategorySingleEnvelopeFromJson(
  Map<String, dynamic> json,
) => CategorySingleEnvelope(
  success: json['success'] as bool,
  message: json['message'] as String,
  result: json['result'] == null
      ? null
      : CategoryDto.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CategorySingleEnvelopeToJson(
  CategorySingleEnvelope instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'result': instance.result,
};

GenreSingleEnvelope _$GenreSingleEnvelopeFromJson(Map<String, dynamic> json) =>
    GenreSingleEnvelope(
      success: json['success'] as bool,
      message: json['message'] as String,
      result: json['result'] == null
          ? null
          : GenreDto.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GenreSingleEnvelopeToJson(
  GenreSingleEnvelope instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'result': instance.result,
};

PaginationDto _$PaginationDtoFromJson(Map<String, dynamic> json) =>
    PaginationDto(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationDtoToJson(PaginationDto instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'total_pages': instance.totalPages,
    };

ContentListResultDto _$ContentListResultDtoFromJson(
  Map<String, dynamic> json,
) => ContentListResultDto(
  items: (json['items'] as List<dynamic>)
      .map((e) => ContentApiDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: PaginationDto.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ContentListResultDtoToJson(
  ContentListResultDto instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'pagination': instance.pagination.toJson(),
};

ContentListEnvelope _$ContentListEnvelopeFromJson(Map<String, dynamic> json) =>
    ContentListEnvelope(
      success: json['success'] as bool,
      message: json['message'] as String,
      result: json['result'] == null
          ? null
          : ContentListResultDto.fromJson(
              json['result'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ContentListEnvelopeToJson(
  ContentListEnvelope instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'result': instance.result,
};

SeasonApiDto _$SeasonApiDtoFromJson(Map<String, dynamic> json) => SeasonApiDto(
  seasonId: json['season_id'] as String,
  contentId: json['content_id'] as String?,
  seasonNumber: (json['season_number'] as num?)?.toInt(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  thumbnailKey: json['thumbnail_key'] as String?,
  status: json['status'] as String?,
  releaseDate: json['release_date'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$SeasonApiDtoToJson(SeasonApiDto instance) =>
    <String, dynamic>{
      'season_id': instance.seasonId,
      'content_id': instance.contentId,
      'season_number': instance.seasonNumber,
      'title': instance.title,
      'description': instance.description,
      'thumbnail_key': instance.thumbnailKey,
      'status': instance.status,
      'release_date': instance.releaseDate,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

EpisodeApiDto _$EpisodeApiDtoFromJson(Map<String, dynamic> json) =>
    EpisodeApiDto(
      episodeId: json['episode_id'] as String,
      contentId: json['content_id'] as String?,
      seasonId: json['season_id'] as String?,
      episodeNumber: (json['episode_number'] as num?)?.toInt(),
      title: json['title'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      shortDescription: json['short_description'] as String?,
      thumbnailKey: json['thumbnail_key'] as String?,
      bannerKey: json['banner_key'] as String?,
      videoKey: json['video_key'] as String?,
      streamManifestKey: json['stream_manifest_key'] as String?,
      videoUploadId: json['video_upload_id'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      accessType: json['access_type'] as String?,
      requiredCoins: (json['required_coins'] as num?)?.toInt(),
      status: json['status'] as String?,
      releaseDate: json['release_date'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$EpisodeApiDtoToJson(EpisodeApiDto instance) =>
    <String, dynamic>{
      'episode_id': instance.episodeId,
      'content_id': instance.contentId,
      'season_id': instance.seasonId,
      'episode_number': instance.episodeNumber,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'short_description': instance.shortDescription,
      'thumbnail_key': instance.thumbnailKey,
      'banner_key': instance.bannerKey,
      'video_key': instance.videoKey,
      'stream_manifest_key': instance.streamManifestKey,
      'video_upload_id': instance.videoUploadId,
      'duration_seconds': instance.durationSeconds,
      'access_type': instance.accessType,
      'required_coins': instance.requiredCoins,
      'status': instance.status,
      'release_date': instance.releaseDate,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

SeasonsListEnvelope _$SeasonsListEnvelopeFromJson(Map<String, dynamic> json) =>
    SeasonsListEnvelope(
      success: json['success'] as bool,
      message: json['message'] as String,
      result: (json['result'] as List<dynamic>?)
          ?.map((e) => SeasonApiDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SeasonsListEnvelopeToJson(
  SeasonsListEnvelope instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'result': instance.result,
};

EpisodesListEnvelope _$EpisodesListEnvelopeFromJson(
  Map<String, dynamic> json,
) => EpisodesListEnvelope(
  success: json['success'] as bool,
  message: json['message'] as String,
  result: (json['result'] as List<dynamic>?)
      ?.map((e) => EpisodeApiDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EpisodesListEnvelopeToJson(
  EpisodesListEnvelope instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'result': instance.result,
};

SeasonSingleEnvelope _$SeasonSingleEnvelopeFromJson(
  Map<String, dynamic> json,
) => SeasonSingleEnvelope(
  success: json['success'] as bool,
  message: json['message'] as String,
  result: json['result'] == null
      ? null
      : SeasonApiDto.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SeasonSingleEnvelopeToJson(
  SeasonSingleEnvelope instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'result': instance.result,
};

EpisodeSingleEnvelope _$EpisodeSingleEnvelopeFromJson(
  Map<String, dynamic> json,
) => EpisodeSingleEnvelope(
  success: json['success'] as bool,
  message: json['message'] as String,
  result: json['result'] == null
      ? null
      : EpisodeApiDto.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EpisodeSingleEnvelopeToJson(
  EpisodeSingleEnvelope instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'result': instance.result,
};

ContentApiDto _$ContentApiDtoFromJson(Map<String, dynamic> json) =>
    ContentApiDto(
      contentId: json['content_id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      shortDescription: json['short_description'] as String?,
      contentType: json['content_type'] as String?,
      isSeries: json['is_series'] as bool?,
      language: json['language'] as String?,
      country: json['country'] as String?,
      ageRating: json['age_rating'] as String?,
      releaseDate: json['release_date'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      totalSeasons: (json['total_seasons'] as num?)?.toInt(),
      totalEpisodes: (json['total_episodes'] as num?)?.toInt(),
      thumbnailKey: json['thumbnail_key'] as String?,
      posterKey: json['poster_key'] as String?,
      bannerKey: json['banner_key'] as String?,
      trailerKey: json['trailer_key'] as String?,
      streamManifestKey: json['stream_manifest_key'] as String?,
      videoUploadId: json['video_upload_id'] as String?,
      accessType: json['access_type'] as String?,
      requiredCoins: (json['required_coins'] as num?)?.toInt(),
      status: json['status'] as String?,
      publishedAt: json['published_at'] as String?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => GenreDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      seasons: (json['seasons'] as List<dynamic>?)
          ?.map((e) => SeasonApiDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      episodes: (json['episodes'] as List<dynamic>?)
          ?.map((e) => EpisodeApiDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ContentApiDtoToJson(ContentApiDto instance) =>
    <String, dynamic>{
      'content_id': instance.contentId,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'short_description': instance.shortDescription,
      'content_type': instance.contentType,
      'is_series': instance.isSeries,
      'language': instance.language,
      'country': instance.country,
      'age_rating': instance.ageRating,
      'release_date': instance.releaseDate,
      'duration_seconds': instance.durationSeconds,
      'total_seasons': instance.totalSeasons,
      'total_episodes': instance.totalEpisodes,
      'thumbnail_key': instance.thumbnailKey,
      'poster_key': instance.posterKey,
      'banner_key': instance.bannerKey,
      'trailer_key': instance.trailerKey,
      'stream_manifest_key': instance.streamManifestKey,
      'video_upload_id': instance.videoUploadId,
      'access_type': instance.accessType,
      'required_coins': instance.requiredCoins,
      'status': instance.status,
      'published_at': instance.publishedAt,
      'categories': instance.categories?.map((e) => e.toJson()).toList(),
      'genres': instance.genres?.map((e) => e.toJson()).toList(),
      'seasons': instance.seasons?.map((e) => e.toJson()).toList(),
      'episodes': instance.episodes?.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

ContentSingleEnvelope _$ContentSingleEnvelopeFromJson(
  Map<String, dynamic> json,
) => ContentSingleEnvelope(
  success: json['success'] as bool,
  message: json['message'] as String,
  result: json['result'] == null
      ? null
      : ContentApiDto.fromJson(json['result'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ContentSingleEnvelopeToJson(
  ContentSingleEnvelope instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'result': instance.result,
};

HlsPlaybackDataDto _$HlsPlaybackDataDtoFromJson(Map<String, dynamic> json) =>
    HlsPlaybackDataDto(
      manifestUrl: json['manifest_url'] as String?,
      queryParams: json['query_params'] as String?,
      baseUrl: json['base_url'] as String?,
      expiresIn: (json['expires_in'] as num?)?.toInt(),
      phase: json['phase'] as String?,
    );

Map<String, dynamic> _$HlsPlaybackDataDtoToJson(HlsPlaybackDataDto instance) =>
    <String, dynamic>{
      'manifest_url': instance.manifestUrl,
      'query_params': instance.queryParams,
      'base_url': instance.baseUrl,
      'expires_in': instance.expiresIn,
      'phase': instance.phase,
    };

HlsPlaybackEnvelope _$HlsPlaybackEnvelopeFromJson(Map<String, dynamic> json) =>
    HlsPlaybackEnvelope(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : HlsPlaybackDataDto.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HlsPlaybackEnvelopeToJson(
  HlsPlaybackEnvelope instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
