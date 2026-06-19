import 'package:dio/dio.dart';

import '../models/payment_history_response_model.dart';

abstract class PaymentHistoryRemoteDataSource {
  Future<PaymentHistoryResponseModel> getPaymentHistory({
    int page = 1,
    int limit = 10,
    DateTime? fromDate,
    DateTime? toDate,
    String? status,
    String? gateway,
  });
}

class PaymentHistoryRemoteDataSourceImpl
    implements PaymentHistoryRemoteDataSource {
  PaymentHistoryRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  final Dio dio;
  final String baseUrl;

  @override
  Future<PaymentHistoryResponseModel> getPaymentHistory({
    int page = 1,
    int limit = 10,
    DateTime? fromDate,
    DateTime? toDate,
    String? status,
    String? gateway,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (fromDate != null) 'from_date': _formatDate(fromDate),
      if (toDate != null) 'to_date': _formatDate(toDate),
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      if (gateway != null && gateway.trim().isNotEmpty)
        'gateway': gateway.trim(),
    };

    final response = await dio.get<Map<String, dynamic>>(
      '$baseUrl/api/wallet/payment-history',
      queryParameters: queryParameters,
      options: Options(
        headers: const <String, String>{'Accept': 'application/json'},
      ),
    );

    final body = response.data;
    if (body == null) {
      throw Exception('Invalid payment history response');
    }

    return PaymentHistoryResponseModel.fromJson(body);
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
