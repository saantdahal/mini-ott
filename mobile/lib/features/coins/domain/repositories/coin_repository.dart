import '../entities/coin_package.dart';
import '../entities/transaction.dart';
import '../entities/wallet.dart';

abstract class CoinRepository {
  /// Get user's wallet information
  Future<Wallet> getWallet();

  /// Get all available coin packages
  Future<List<CoinPackage>> getCoinPackages();

  /// Get transaction history
  Future<List<Transaction>> getTransactionHistory({
    int page = 1,
    int limit = 20,
  });

  /// Initiate coin purchase
  Future<Map<String, dynamic>> initiatePurchase({
    required String packageId,
    required String paymentMethod,
  });

  /// Verify payment transaction
  Future<bool> verifyPayment({
    required String transactionId,
    required String pidx,
  });
}
