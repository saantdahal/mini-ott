import '../../domain/entities/coin_package.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';

const _coinStateUnset = Object();

class CoinState {
  final Wallet? wallet;
  final List<CoinPackage> coinPackages;
  final List<Transaction> transactions;
  final String? selectedPaymentMethod; // 'khalti', 'esewa'
  final String? selectedPackageId;
  final bool isLoading;
  final String? errorMessage;
  final CoinActionType actionType;

  /// Flips to true the first time `initializeData` finishes (success or
  /// failure). Drives the cold-start skeleton: false → show skeleton, true →
  /// render real content. Stays true across pull-to-refresh so the inline
  /// `RefreshIndicator` handles subsequent loads.
  final bool isFirstLoadComplete;

  const CoinState({
    this.wallet,
    this.coinPackages = const [],
    this.transactions = const [],
    this.selectedPaymentMethod,
    this.selectedPackageId,
    this.isLoading = false,
    this.errorMessage,
    this.actionType = CoinActionType.idle,
    this.isFirstLoadComplete = false,
  });

  CoinState copyWith({
    Wallet? wallet,
    List<CoinPackage>? coinPackages,
    List<Transaction>? transactions,
    String? selectedPaymentMethod,
    Object? selectedPackageId = _coinStateUnset,
    bool? isLoading,
    String? errorMessage,
    CoinActionType? actionType,
    bool? isFirstLoadComplete,
  }) {
    return CoinState(
      wallet: wallet ?? this.wallet,
      coinPackages: coinPackages ?? this.coinPackages,
      transactions: transactions ?? this.transactions,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedPackageId: identical(selectedPackageId, _coinStateUnset)
          ? this.selectedPackageId
          : selectedPackageId as String?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      actionType: actionType ?? this.actionType,
      isFirstLoadComplete: isFirstLoadComplete ?? this.isFirstLoadComplete,
    );
  }

  // UI helper getters for fine-grained rebuilds
  bool get isWalletLoading =>
      isLoading && actionType == CoinActionType.fetchingWallet;
  bool get isPackagesLoading =>
      isLoading && actionType == CoinActionType.fetchingPackages;
  bool get isTransactionsLoading =>
      isLoading && actionType == CoinActionType.fetchingTransactions;
  bool get isPurchasing => isLoading && actionType == CoinActionType.purchasing;
  bool get hasError => errorMessage != null;
  bool get hasWallet => wallet != null;
  bool get hasPackages => coinPackages.isNotEmpty;

  @override
  String toString() =>
      'CoinState(wallet: $wallet, packages: ${coinPackages.length}, transactions: ${transactions.length}, actionType: $actionType)';
}

enum CoinActionType {
  idle,
  fetchingWallet,
  fetchingPackages,
  fetchingTransactions,
  purchasing,
}
