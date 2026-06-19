import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/coin_di.dart';
import '../../domain/usecases/coin_use_cases.dart';
import 'coin_state.dart';

import 'dart:async' show unawaited;

class CoinNotifier extends Notifier<CoinState> {
  late GetWalletUseCase _getWalletUseCase;
  late GetCoinPackagesUseCase _getCoinPackagesUseCase;
  late GetTransactionHistoryUseCase _getTransactionHistoryUseCase;
  late InitiatePurchaseUseCase _initiatePurchaseUseCase;

  @override
  CoinState build() {
    // Initialize use cases from ref (will be provided via DI)
    _getWalletUseCase = ref.read(getWalletUseCaseProvider);
    _getCoinPackagesUseCase = ref.read(getCoinPackagesUseCaseProvider);
    _getTransactionHistoryUseCase = ref.read(
      getTransactionHistoryUseCaseProvider,
    );
    _initiatePurchaseUseCase = ref.read(initiatePurchaseUseCaseProvider);

    return const CoinState();
  }

  /// Public method to initialize data - call from UI layer
  Future<void> initializeData() async {
    if (state.isFirstLoadComplete) {
      // Already warmed up — caller probably wants a refresh; route through
      // the dedicated fetchers so the cold-start skeleton stays hidden.
      await Future.wait<void>([fetchWallet(), fetchCoinPackages()]);
      unawaited(fetchTransactionHistory());
      return;
    }
    try {
      await fetchWallet();
      await fetchCoinPackages();
      // Transaction history is optional - don't fail if endpoint missing
      unawaited(fetchTransactionHistory());
    } finally {
      state = state.copyWith(isFirstLoadComplete: true);
    }
  }

  Future<void> fetchWallet() async {
    state = state.copyWith(
      isLoading: true,
      actionType: CoinActionType.fetchingWallet,
      errorMessage: null,
    );

    try {
      final wallet = await _getWalletUseCase.call();
      state = state.copyWith(
        wallet: wallet,
        isLoading: false,
        actionType: CoinActionType.idle,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        actionType: CoinActionType.idle,
      );
    }
  }

  Future<void> fetchCoinPackages() async {
    state = state.copyWith(
      isLoading: true,
      actionType: CoinActionType.fetchingPackages,
      errorMessage: null,
    );

    try {
      final packages = await _getCoinPackagesUseCase.call();
      state = state.copyWith(
        coinPackages: packages,
        isLoading: false,
        actionType: CoinActionType.idle,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        actionType: CoinActionType.idle,
      );
    }
  }

  Future<void> fetchTransactionHistory() async {
    try {
      final transactions = await _getTransactionHistoryUseCase.call();
      state = state.copyWith(transactions: transactions);
    } catch (e) {
      // Silently fail if transaction endpoint not available
      // This is optional data, not critical
      debugPrint('Failed to fetch transactions: $e');
    }
  }

  void selectPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void selectCoinPackage(String packageId) {
    state = state.copyWith(selectedPackageId: packageId);
  }

  void clearCoinPackageSelection() {
    state = state.copyWith(selectedPackageId: null);
  }

  Future<void> initiatePurchase({
    required String packageId,
    required String paymentMethod,
  }) async {
    state = state.copyWith(
      isLoading: true,
      actionType: CoinActionType.purchasing,
      errorMessage: null,
    );

    try {
      await _initiatePurchaseUseCase.call(
        packageId: packageId,
        paymentMethod: paymentMethod,
      );
      state = state.copyWith(isLoading: false, actionType: CoinActionType.idle);
      // Result contains payment URL or transaction ID
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        actionType: CoinActionType.idle,
      );
    }
  }
}
