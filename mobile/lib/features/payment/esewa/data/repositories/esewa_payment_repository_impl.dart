import '../../domain/entities/esewa_epay_init_result.dart';
import '../../domain/repositories/esewa_payment_repository.dart';
import '../esewa_payment_remote_data_source.dart';

class EsewaPaymentRepositoryImpl implements EsewaPaymentRepository {
  EsewaPaymentRepositoryImpl(this._remote);

  final EsewaPaymentRemoteDataSource _remote;

  @override
  Future<EsewaEpayInitResult> initializeWebviewCheckout({
    required String packageId,
    required double price,
    required String productName,
  }) {
    return _remote.initializeWebviewCheckout(
      packageId: packageId,
      price: price,
      productName: productName,
    );
  }
}
