import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../domain/entities/khalti_checkout_session.dart';

abstract class KhaltiPaymentRemoteDataSource {
  Future<KhaltiCheckoutSession> initializeCheckout({
    required String packageId,
    required double price,
    required String packageName,
    required String websiteUrl,
  });
}

class KhaltiPaymentRemoteDataSourceImpl implements KhaltiPaymentRemoteDataSource {
  KhaltiPaymentRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  final Dio dio;
  final String baseUrl;

  @override
  Future<KhaltiCheckoutSession> initializeCheckout({
    required String packageId,
    required double price,
    required String packageName,
    required String websiteUrl,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '$baseUrl/api/khalti/initialize-payment',
        data: <String, dynamic>{
          'packageId': packageId,
          'price': price,
          'packageName': packageName,
          'website_url': websiteUrl,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const AppException(message: 'Invalid Khalti response');
      }

      final paymentInitiate = body['paymentInitiate'];
      if (paymentInitiate is! Map<String, dynamic>) {
        throw const AppException(message: 'Missing paymentInitiate');
      }

      final paymentUrl =
          paymentInitiate['payment_url']?.toString() ??
          paymentInitiate['paymentUrl']?.toString();
      if (paymentUrl == null || paymentUrl.isEmpty) {
        throw const AppException(message: 'Missing Khalti payment_url');
      }

      final pending = body['createPendingPurchase'];
      String? purchaseOrderId;
      if (pending is Map<String, dynamic>) {
        purchaseOrderId =
            pending['payment_id']?.toString() ??
            pending['paymentId']?.toString();
      }
      if (purchaseOrderId == null || purchaseOrderId.isEmpty) {
        throw const AppException(message: 'Missing purchase order id');
      }

      final amountPaisa = (price * 100).round();

      return KhaltiCheckoutSession(
        paymentUrl: paymentUrl,
        purchaseOrderId: purchaseOrderId,
        amountPaisa: amountPaisa,
        packageName: packageName,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String? msg;
      if (data is Map) {
        msg = data['message'] as String? ?? data['error'] as String?;
      }
      throw AppException(message: msg ?? e.message ?? 'Network error');
    }
  }
}
