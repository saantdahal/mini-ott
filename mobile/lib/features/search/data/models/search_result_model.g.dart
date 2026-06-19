// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResultModel _$SearchResultModelFromJson(Map<String, dynamic> json) =>
    SearchResultModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      posterUrl: json['poster_url'] as String,
      contentType: json['content_type'] as String,
      genres: (json['genres'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      rating: (json['rating'] as num).toDouble(),
      duration: json['duration'] as String,
      isTrending: json['is_trending'] as bool,
      isPremium: json['is_premium'] as bool,
    );

Map<String, dynamic> _$SearchResultModelToJson(SearchResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'poster_url': instance.posterUrl,
      'content_type': instance.contentType,
      'genres': instance.genres,
      'rating': instance.rating,
      'duration': instance.duration,
      'is_trending': instance.isTrending,
      'is_premium': instance.isPremium,
    };
