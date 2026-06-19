import 'package:json_annotation/json_annotation.dart';

part 'search_result_model.g.dart';

@JsonSerializable()
class SearchResultModel {
  final String id;
  final String title;
  final String description;
  @JsonKey(name: 'poster_url')
  final String posterUrl;
  @JsonKey(name: 'content_type')
  final String contentType;
  final List<String> genres;
  final double rating;
  final String duration;
  @JsonKey(name: 'is_trending')
  final bool isTrending;
  @JsonKey(name: 'is_premium')
  final bool isPremium;

  SearchResultModel({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.contentType,
    required this.genres,
    required this.rating,
    required this.duration,
    required this.isTrending,
    required this.isPremium,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) =>
      _$SearchResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResultModelToJson(this);
}
