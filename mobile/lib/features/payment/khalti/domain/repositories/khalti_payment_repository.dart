import '../entities/khalti_checkout_session.dart';

abstract class KhaltiPaymentRepository {
  Future<KhaltiCheckoutSession> initializeCheckout({
    required String packageId,
    required double price,
    required String packageName,
    required String websiteUrl,
  });
}
