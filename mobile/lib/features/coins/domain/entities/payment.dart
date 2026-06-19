class Payment {
  final String id;
  final String userId;
  final String coinPackageId;
  final String method; // 'khalti', 'esewa'
  final double amount;
  final String status; // 'pending', 'success', 'failed'
  final String transactionId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Payment({
    required this.id,
    required this.userId,
    required this.coinPackageId,
    required this.method,
    required this.amount,
    required this.status,
    required this.transactionId,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  Payment copyWith({
    String? id,
    String? userId,
    String? coinPackageId,
    String? method,
    double? amount,
    String? status,
    String? transactionId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      coinPackageId: coinPackageId ?? this.coinPackageId,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Payment &&
        other.id == id &&
        other.userId == userId &&
        other.coinPackageId == coinPackageId &&
        other.method == method &&
        other.amount == amount &&
        other.status == status &&
        other.transactionId == transactionId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        coinPackageId.hashCode ^
        method.hashCode ^
        amount.hashCode ^
        status.hashCode ^
        transactionId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Payment(id: $id, userId: $userId, method: $method, status: $status, amount: $amount)';
  }
}
