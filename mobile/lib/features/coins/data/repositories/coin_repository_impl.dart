import '../../domain/entities/coin_package.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/coin_repository.dart';
import '../datasources/coin_remote_data_source.dart';
import '../models/coin_package_model.dart';
import '../models/wallet_model.dart';

class CoinRepositoryImpl implements CoinRepository {
  final CoinRemoteDataSource remoteDataSource;

  CoinRepositoryImpl(this.remoteDataSource);

  @override
  Future<Wallet> getWallet() async {
    try {
      final response = await remoteDataSource.getWallet();
      return _mapWalletModelToEntity(response.data.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CoinPackage>> getCoinPackages() async {
    try {
      final response = await remoteDataSource.getCoinPackages();
      return response.data.result
          .map((model) => _mapCoinPackageModelToEntity(model))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getTransactionHistory({
    int page = 1,
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> initiatePurchase({
    required String packageId,
    required String paymentMethod,
  }) async {
    throw UnsupportedError(
      'Server has no /api/payments/initiate. Use Khalti or eSewa checkout from the coin screen.',
    );
  }

  @override
  Future<bool> verifyPayment({
    required String transactionId,
    required String pidx,
  }) async {
    throw UnsupportedError(
      'Server has no /api/payments/verify. Complete payment via gateway callbacks.',
    );
  }

  // Mappers
  Wallet _mapWalletModelToEntity(WalletModel model) {
    return Wallet(
      userId: model.userId,
      balanceCoins: model.balanceCoins,
      totalEarned: model.totalEarned,
      totalSpent: model.totalSpent,
    );
  }

  CoinPackage _mapCoinPackageModelToEntity(CoinPackageModel model) {
    return CoinPackage(
      id: model.id,
      title: model.title,
      coins: model.coins,
      bonusCoins: model.bonusCoins,
      price: model.price,
      currency: model.currency,
      isPopular: model.isPopular,
      description: model.description,
      sortOrder: model.sortOrder,
      status: model.status,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

}
