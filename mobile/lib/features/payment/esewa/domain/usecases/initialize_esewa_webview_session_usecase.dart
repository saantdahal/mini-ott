import '../entities/esewa_epay_init_result.dart';
import '../repositories/esewa_payment_repository.dart';

class InitializeEsewaWebviewSessionUseCase {
  InitializeEsewaWebviewSessionUseCase(this._repository);

  final EsewaPaymentRepository _repository;

  Future<EsewaEpayInitResult> call({
    required String packageId,
    required double price,
    required String productName,
  }) {
    return _repository.initializeWebviewCheckout(
      packageId: packageId,
      price: price,
      productName: productName,
    );
  }
}
