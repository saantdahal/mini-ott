import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  /// Initialize Khalti payment
  Future<String> initiateKhaltiPayment({
    required String amount,
    required String coinPackageId,
  });

  /// Verify Khalti payment
  Future<PaymentModel> verifyKhaltiPayment({
    required String pidx,
    required String transactionId,
  });

  /// Get payment status
  Future<PaymentModel> getPaymentStatus({required String paymentId});

  /// List user payments
  Future<List<PaymentModel>> listPayments({
    required int limit,
    required int offset,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  PaymentRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
  Future<String> initiateKhaltiPayment({
    required String amount,
    required String coinPackageId,
  }) async {
    try {
      final parsedPrice = double.tryParse(amount);
      if (parsedPrice == null) {
        throw const AppException(message: 'Invalid amount');
      }
      final response = await dio.post(
        '$baseUrl/api/khalti/initialize-payment',
        data: {
          'packageId': coinPackageId,
          'price': parsedPrice,
          'packageName': 'Coin Package',
          'website_url': baseUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data as Map<String, dynamic>?;
        final initiate = body?['paymentInitiate'] as Map<String, dynamic>?;
        if (initiate == null) {
          throw AppException(message: 'Invalid response format');
        }
        final paymentUrl =
            initiate['payment_url']?.toString() ??
            initiate['paymentUrl']?.toString();
        if (paymentUrl == null || paymentUrl.isEmpty) {
          throw AppException(message: 'Missing payment url');
        }
        return paymentUrl;
      } else {
        throw AppException(
          message:
              response.data['message'] ?? 'Failed to initiate Khalti payment',
        );
      }
    } on DioException catch (e) {
      throw AppException(message: e.message ?? 'Network error');
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<PaymentModel> verifyKhaltiPayment({
    required String pidx,
    required String transactionId,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/khalti/complete-khalti-payment',
        queryParameters: {'pidx': pidx, 'transaction_id': transactionId},
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>?;
        final data = body?['payment'] as Map<String, dynamic>?;
        if (data == null) {
          throw AppException(message: 'Invalid response format');
        }
        return PaymentModel.fromJson(data);
      } else {
        throw AppException(
          message:
              response.data['message'] ?? 'Failed to verify Khalti payment',
        );
      }
    } on DioException catch (e) {
      throw AppException(message: e.message ?? 'Network error');
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<PaymentModel> getPaymentStatus({required String paymentId}) async {
    throw const AppException(
      message: 'Payment status endpoint is not available in current backend.',
    );
  }

  @override
  Future<List<PaymentModel>> listPayments({
    required int limit,
    required int offset,
  }) async {
    throw const AppException(
      message: 'Payment list endpoint is not available in current backend.',
    );
  }
}
