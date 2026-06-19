// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinPackageModel _$CoinPackageModelFromJson(Map<String, dynamic> json) =>
    CoinPackageModel(
      id: json['coin_package_id'] as String,
      title: json['title'] as String,
      coins: (json['coins'] as num).toInt(),
      bonusCoins: (json['bonus_coins'] as num).toInt(),
      price: CoinPackageModel._parsePrice(json['price_amount']),
      currency: json['currency'] as String,
      isPopular: json['is_popular'] as bool,
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CoinPackageModelToJson(CoinPackageModel instance) =>
    <String, dynamic>{
      'coin_package_id': instance.id,
      'title': instance.title,
      'coins': instance.coins,
      'bonus_coins': instance.bonusCoins,
      'price_amount': instance.price,
      'currency': instance.currency,
      'is_popular': instance.isPopular,
      'description': instance.description,
      'sort_order': instance.sortOrder,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
