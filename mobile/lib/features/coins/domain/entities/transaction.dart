class Transaction {
  final String id;
  final String type; // 'purchase', 'reward', 'usage'
  final int amount;
  final double price;
  final String currency;
  final String status; // 'success', 'pending', 'failed'
  final String? paymentMethod; // 'khalti', 'esewa'
  final DateTime createdAt;
  final String? description;

  const Transaction({
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

  Transaction copyWith({
    String? id,
    String? type,
    int? amount,
    double? price,
    String? currency,
    String? status,
    String? paymentMethod,
    DateTime? createdAt,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.type == type &&
        other.amount == amount &&
        other.status == status;
  }

  @override
  int get hashCode =>
      id.hashCode ^ type.hashCode ^ amount.hashCode ^ status.hashCode;

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, status: $status)';
  }
}
