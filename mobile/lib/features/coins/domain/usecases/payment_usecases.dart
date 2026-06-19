import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class InitiateKhaltiPaymentUseCase {
  final PaymentRepository repository;

  InitiateKhaltiPaymentUseCase(this.repository);

  Future<String> call({required String amount, required String coinPackageId}) {
    return repository.initiateKhaltiPayment(
      amount: amount,
      coinPackageId: coinPackageId,
    );
  }
}

class VerifyKhaltiPaymentUseCase {
  final PaymentRepository repository;

  VerifyKhaltiPaymentUseCase(this.repository);

  Future<Payment> call({required String pidx, required String transactionId}) {
    return repository.verifyKhaltiPayment(
      pidx: pidx,
      transactionId: transactionId,
    );
  }
}

class GetPaymentStatusUseCase {
  final PaymentRepository repository;

  GetPaymentStatusUseCase(this.repository);

  Future<Payment> call({required String paymentId}) {
    return repository.getPaymentStatus(paymentId: paymentId);
  }
}

class ListPaymentsUseCase {
  final PaymentRepository repository;

  ListPaymentsUseCase(this.repository);

  Future<List<Payment>> call({required int limit, required int offset}) {
    return repository.listPayments(limit: limit, offset: offset);
  }
}
