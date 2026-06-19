import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> initiateKhaltiPayment({
    required String amount,
    required String coinPackageId,
  }) async {
    return remoteDataSource.initiateKhaltiPayment(
      amount: amount,
      coinPackageId: coinPackageId,
    );
  }

  @override
  Future<Payment> verifyKhaltiPayment({
    required String pidx,
    required String transactionId,
  }) async {
    final model = await remoteDataSource.verifyKhaltiPayment(
      pidx: pidx,
      transactionId: transactionId,
    );
    return model.toEntity();
  }

  @override
  Future<Payment> getPaymentStatus({required String paymentId}) async {
    final model = await remoteDataSource.getPaymentStatus(paymentId: paymentId);
    return model.toEntity();
  }

  @override
  Future<List<Payment>> listPayments({
    required int limit,
    required int offset,
  }) async {
    final models = await remoteDataSource.listPayments(
      limit: limit,
      offset: offset,
    );
    return models.map((e) => e.toEntity()).toList();
  }
}
