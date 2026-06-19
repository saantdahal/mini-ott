import '../entities/coin_package.dart';
import '../entities/transaction.dart';
import '../entities/wallet.dart';
import '../repositories/coin_repository.dart';

class GetWalletUseCase {
  final CoinRepository repository;

  const GetWalletUseCase(this.repository);

  Future<Wallet> call() async {
    return repository.getWallet();
  }
}

class GetCoinPackagesUseCase {
  final CoinRepository repository;

  const GetCoinPackagesUseCase(this.repository);

  Future<List<CoinPackage>> call() async {
    return repository.getCoinPackages();
  }
}

class GetTransactionHistoryUseCase {
  final CoinRepository repository;

  const GetTransactionHistoryUseCase(this.repository);

  Future<List<Transaction>> call({int page = 1, int limit = 20}) async {
    return repository.getTransactionHistory(page: page, limit: limit);
  }
}

class InitiatePurchaseUseCase {
  final CoinRepository repository;

  const InitiatePurchaseUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String packageId,
    required String paymentMethod,
  }) async {
    return repository.initiatePurchase(
      packageId: packageId,
      paymentMethod: paymentMethod,
    );
  }
}

class VerifyPaymentUseCase {
  final CoinRepository repository;

  const VerifyPaymentUseCase(this.repository);

  Future<bool> call({
    required String transactionId,
    required String pidx,
  }) async {
    return repository.verifyPayment(transactionId: transactionId, pidx: pidx);
  }
}
