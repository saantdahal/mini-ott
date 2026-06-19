// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
  userId: json['user_id'] as String,
  balanceCoins: WalletModel._toInt(json['balance_coins']),
  totalEarned: WalletModel._toInt(json['total_earned_coins']),
  totalSpent: WalletModel._toInt(json['total_spent_coins']),
);

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'balance_coins': instance.balanceCoins,
      'total_earned_coins': instance.totalEarned,
      'total_spent_coins': instance.totalSpent,
    };
