class Wallet {
  final String userId;
  final int balanceCoins;
  final int totalEarned;
  final int totalSpent;

  const Wallet({
    required this.userId,
    required this.balanceCoins,
    required this.totalEarned,
    required this.totalSpent,
  });

  Wallet copyWith({
    String? userId,
    int? balanceCoins,
    int? totalEarned,
    int? totalSpent,
  }) {
    return Wallet(
      userId: userId ?? this.userId,
      balanceCoins: balanceCoins ?? this.balanceCoins,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Wallet &&
        other.userId == userId &&
        other.balanceCoins == balanceCoins &&
        other.totalEarned == totalEarned &&
        other.totalSpent == totalSpent;
  }

  @override
  int get hashCode =>
      userId.hashCode ^
      balanceCoins.hashCode ^
      totalEarned.hashCode ^
      totalSpent.hashCode;

  @override
  String toString() {
    return 'Wallet(userId: $userId, balanceCoins: $balanceCoins, totalEarned: $totalEarned, totalSpent: $totalSpent)';
  }
}
