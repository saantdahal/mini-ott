import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/coin_remote_data_source.dart';
import '../data/datasources/payment_remote_data_source.dart';
import '../data/repositories/coin_repository_impl.dart';
import '../data/repositories/payment_repository_impl.dart';
import '../domain/repositories/coin_repository.dart';
import '../domain/repositories/payment_repository.dart';
import '../domain/usecases/coin_use_cases.dart';
import '../domain/usecases/payment_usecases.dart';

final getIt = GetIt.instance;

/// Coin Repository Provider
final coinRepositoryProvider = Provider<CoinRepository>((ref) {
  final remoteDataSource = getIt<CoinRemoteDataSource>();
  return CoinRepositoryImpl(remoteDataSource);
});

/// Payment Repository Provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final remoteDataSource = getIt<PaymentRemoteDataSource>();
  return PaymentRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Use Case Providers
final getWalletUseCaseProvider = Provider((ref) {
  return GetWalletUseCase(ref.watch(coinRepositoryProvider));
});

final getCoinPackagesUseCaseProvider = Provider((ref) {
  return GetCoinPackagesUseCase(ref.watch(coinRepositoryProvider));
});

final getTransactionHistoryUseCaseProvider = Provider((ref) {
  return GetTransactionHistoryUseCase(ref.watch(coinRepositoryProvider));
});

final initiatePurchaseUseCaseProvider = Provider((ref) {
  return InitiatePurchaseUseCase(ref.watch(coinRepositoryProvider));
});

final verifyPaymentUseCaseProvider = Provider((ref) {
  return VerifyPaymentUseCase(ref.watch(coinRepositoryProvider));
});

/// Payment Use Case Providers
final initiateKhaltiPaymentUseCaseProvider = Provider((ref) {
  return InitiateKhaltiPaymentUseCase(ref.watch(paymentRepositoryProvider));
});

final verifyKhaltiPaymentUseCaseProvider = Provider((ref) {
  return VerifyKhaltiPaymentUseCase(ref.watch(paymentRepositoryProvider));
});

final getPaymentStatusUseCaseProvider = Provider((ref) {
  return GetPaymentStatusUseCase(ref.watch(paymentRepositoryProvider));
});

final listPaymentsUseCaseProvider = Provider((ref) {
  return ListPaymentsUseCase(ref.watch(paymentRepositoryProvider));
});
