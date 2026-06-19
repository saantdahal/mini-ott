import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class WalletModel {
  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'balance_coins', fromJson: _toInt)
  final int balanceCoins;

  @JsonKey(name: 'total_earned_coins', fromJson: _toInt)
  final int totalEarned;

  @JsonKey(name: 'total_spent_coins', fromJson: _toInt)
  final int totalSpent;

  const WalletModel({
    required this.userId,
    required this.balanceCoins,
    required this.totalEarned,
    required this.totalSpent,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }
}
