import '../entities/esewa_epay_init_result.dart';

abstract class EsewaPaymentRepository {
  Future<EsewaEpayInitResult> initializeWebviewCheckout({
    required String packageId,
    required double price,
    required String productName,
  });
}
