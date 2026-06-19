import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../domain/entities/esewa_epay_init_result.dart';

abstract class EsewaPaymentRemoteDataSource {
  Future<EsewaEpayInitResult> initializeWebviewCheckout({
    required String packageId,
    required double price,
    required String productName,
  });
}

class EsewaPaymentRemoteDataSourceImpl implements EsewaPaymentRemoteDataSource {
  EsewaPaymentRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  final Dio dio;
  final String baseUrl;

  @override
  Future<EsewaEpayInitResult> initializeWebviewCheckout({
    required String packageId,
    required double price,
    required String productName,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '$baseUrl/api/esewa/initialize-payment',
        data: <String, dynamic>{'packageId': packageId, 'price': price},
      );

      final body = response.data;
      if (body == null || body['success'] != true) {
        final msg = body?['message'] as String? ?? body?['error'] as String?;
        throw AppException(message: msg ?? 'Failed to start eSewa payment');
      }

      final payment = body['payment'] as Map<String, dynamic>?;
      if (payment == null) {
        throw const AppException(message: 'Invalid eSewa response');
      }

      final totalAmount = payment['total_amount']?.toString();
      final transactionUuid = payment['transaction_uuid']?.toString();
      final productCode = payment['product_code']?.toString();
      final signature = payment['signature']?.toString();
      final signedFieldNames = payment['signed_field_names']?.toString();
      final successUrl = payment['success_url']?.toString();
      final failureUrl = payment['failure_url']?.toString();
      final gatewayUrl = payment['gateway_url']?.toString();
      final gatewayActionUrl = payment['gateway_action_url']?.toString();

      if (totalAmount == null ||
          transactionUuid == null ||
          productCode == null ||
          signature == null ||
          signedFieldNames == null ||
          successUrl == null ||
          failureUrl == null ||
          gatewayUrl == null ||
          gatewayActionUrl == null) {
        throw const AppException(message: 'Incomplete eSewa payment payload');
      }

      return EsewaEpayInitResult(
        paymentId: transactionUuid,
        totalAmount: totalAmount,
        productName: productName,
        productCode: productCode,
        signature: signature,
        signedFieldNames: signedFieldNames,
        successUrl: successUrl,
        failureUrl: failureUrl,
        gatewayUrl: gatewayUrl,
        gatewayActionUrl: gatewayActionUrl,
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
