import 'package:json_annotation/json_annotation.dart';

part 'coin_package_model.g.dart';

// Custom converter for String to double
class StringToDoubleConverter implements JsonConverter<double, dynamic> {
  const StringToDoubleConverter();

  @override
  double fromJson(dynamic json) {
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) return double.parse(json);
    throw FormatException('Cannot convert $json to double');
  }

  @override
  dynamic toJson(double object) => object;
}

@JsonSerializable()
class CoinPackageModel {
  @JsonKey(name: 'coin_package_id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'coins')
  final int coins;

  @JsonKey(name: 'bonus_coins')
  final int bonusCoins;

  @JsonKey(name: 'price_amount', fromJson: _parsePrice)
  final double price;

  @JsonKey(name: 'currency')
  final String currency;

  @JsonKey(name: 'is_popular')
  final bool isPopular;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'sort_order')
  final int sortOrder;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const CoinPackageModel({
    required this.id,
    required this.title,
    required this.coins,
    required this.bonusCoins,
    required this.price,
    required this.currency,
    required this.isPopular,
    this.description,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoinPackageModel.fromJson(Map<String, dynamic> json) =>
      _$CoinPackageModelFromJson(json);

  Map<String, dynamic> toJson() => _$CoinPackageModelToJson(this);

  // Parse price from String or num
  static double _parsePrice(dynamic json) {
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) return double.parse(json);
    throw FormatException('Cannot convert $json to double');
  }
}
