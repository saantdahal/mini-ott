import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di.dart';
import '../../data/datasources/payment_history_remote_data_source.dart';
import 'payment_history_state.dart';

class PaymentHistoryNotifier extends Notifier<PaymentHistoryState> {
  late PaymentHistoryRemoteDataSource _remoteDataSource;

  @override
  PaymentHistoryState build() {
    _remoteDataSource = getIt<PaymentHistoryRemoteDataSource>();
    return const PaymentHistoryState();
  }

  Future<void> loadPaymentHistory({
    int page = 1,
    int limit = 10,
    DateTime? fromDate,
    DateTime? toDate,
    String? status,
    String? gateway,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      actionType: PaymentHistoryActionType.fetchingHistory,
    );

    try {
      final response = await _remoteDataSource.getPaymentHistory(
        page: page,
        limit: limit,
        fromDate: fromDate,
        toDate: toDate,
        status: status,
        gateway: gateway,
      );

      state = state.copyWith(
        items: response.data.items,
        pagination: response.data.pagination,
        filters: response.data.filters,
        isLoading: false,
        actionType: PaymentHistoryActionType.idle,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        actionType: PaymentHistoryActionType.idle,
      );
    }
  }
}
