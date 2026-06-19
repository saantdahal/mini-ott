import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.userId,
    required super.coinPackageId,
    required super.method,
    required super.amount,
    required super.status,
    required super.transactionId,
    super.metadata,
    required super.createdAt,
    super.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      coinPackageId: json['coin_package_id'] ?? '',
      method: json['method'] ?? 'unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      transactionId: json['transaction_id'] ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toString(),
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'coin_package_id': coinPackageId,
      'method': method,
      'amount': amount,
      'status': status,
      'transaction_id': transactionId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Payment toEntity() {
    return Payment(
      id: id,
      userId: userId,
      coinPackageId: coinPackageId,
      method: method,
      amount: amount,
      status: status,
      transactionId: transactionId,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
