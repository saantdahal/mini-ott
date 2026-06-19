import '../../domain/entities/khalti_checkout_session.dart';
import '../../domain/repositories/khalti_payment_repository.dart';
import '../khalti_payment_remote_data_source.dart';

class KhaltiPaymentRepositoryImpl implements KhaltiPaymentRepository {
  KhaltiPaymentRepositoryImpl(this._remote);

  final KhaltiPaymentRemoteDataSource _remote;

  @override
  Future<KhaltiCheckoutSession> initializeCheckout({
    required String packageId,
    required double price,
    required String packageName,
    required String websiteUrl,
  }) {
    return _remote.initializeCheckout(
      packageId: packageId,
      price: price,
      packageName: packageName,
      websiteUrl: websiteUrl,
    );
  }
}
