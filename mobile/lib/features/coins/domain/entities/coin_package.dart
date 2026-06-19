class CoinPackage {
  final String id;
  final String title;
  final int coins;
  final int bonusCoins;
  final double price;
  final String currency;
  final bool isPopular;
  final String? description;
  final int sortOrder;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CoinPackage({
    required this.id,
    required this.title,
    required this.coins,
    required this.bonusCoins,
    required this.price,
    required this.currency,
    this.isPopular = false,
    this.description,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  CoinPackage copyWith({
    String? id,
    String? title,
    int? coins,
    int? bonusCoins,
    double? price,
    String? currency,
    bool? isPopular,
    String? description,
    int? sortOrder,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CoinPackage(
      id: id ?? this.id,
      title: title ?? this.title,
      coins: coins ?? this.coins,
      bonusCoins: bonusCoins ?? this.bonusCoins,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isPopular: isPopular ?? this.isPopular,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoinPackage &&
        other.id == id &&
        other.title == title &&
        other.coins == coins &&
        other.bonusCoins == bonusCoins &&
        other.price == price &&
        other.currency == currency &&
        other.isPopular == isPopular &&
        other.sortOrder == sortOrder &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        coins.hashCode ^
        bonusCoins.hashCode ^
        price.hashCode ^
        currency.hashCode ^
        isPopular.hashCode ^
        sortOrder.hashCode ^
        status.hashCode;
  }

  @override
  String toString() {
    return 'CoinPackage(id: $id, title: $title, coins: $coins, bonusCoins: $bonusCoins, price: $price, isPopular: $isPopular, status: $status)';
  }
}
