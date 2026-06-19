import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'amount')
  final int amount;

  @JsonKey(name: 'price')
  final double price;

  @JsonKey(name: 'currency')
  final String currency;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'description')
  final String? description;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.price,
    required this.currency,
    required this.status,
    this.paymentMethod,
    required this.createdAt,
    this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
