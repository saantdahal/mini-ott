import '../entities/khalti_checkout_session.dart';
import '../repositories/khalti_payment_repository.dart';

class InitializeKhaltiCheckoutUseCase {
  InitializeKhaltiCheckoutUseCase(this._repository);

  final KhaltiPaymentRepository _repository;

  Future<KhaltiCheckoutSession> call({
    required String packageId,
    required double price,
    required String packageName,
    required String websiteUrl,
  }) {
    return _repository.initializeCheckout(
      packageId: packageId,
      price: price,
      packageName: packageName,
      websiteUrl: websiteUrl,
    );
  }
}
