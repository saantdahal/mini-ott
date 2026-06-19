import '../entities/payment.dart';

abstract class PaymentRepository {
  /// Initialize Khalti payment
  Future<String> initiateKhaltiPayment({
    required String amount,
    required String coinPackageId,
  });

  /// Verify Khalti payment
  Future<Payment> verifyKhaltiPayment({
    required String pidx,
    required String transactionId,
  });

  /// Get payment status
  Future<Payment> getPaymentStatus({required String paymentId});

  /// List user payments
  Future<List<Payment>> listPayments({required int limit, required int offset});
}
