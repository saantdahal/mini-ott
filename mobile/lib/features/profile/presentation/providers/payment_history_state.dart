import '../../data/models/payment_history_response_model.dart';

const _paymentHistoryUnset = Object();

class PaymentHistoryState {
  const PaymentHistoryState({
    this.items = const [],
    this.pagination,
    this.filters,
    this.isLoading = false,
    this.errorMessage,
    this.actionType = PaymentHistoryActionType.idle,
  });

  final List<PaymentHistoryItemModel> items;
  final PaymentHistoryPaginationModel? pagination;
  final PaymentHistoryFiltersModel? filters;
  final bool isLoading;
  final String? errorMessage;
  final PaymentHistoryActionType actionType;

  PaymentHistoryState copyWith({
    List<PaymentHistoryItemModel>? items,
    Object? pagination = _paymentHistoryUnset,
    Object? filters = _paymentHistoryUnset,
    bool? isLoading,
    Object? errorMessage = _paymentHistoryUnset,
    PaymentHistoryActionType? actionType,
  }) {
    return PaymentHistoryState(
      items: items ?? this.items,
      pagination: identical(pagination, _paymentHistoryUnset)
          ? this.pagination
          : pagination as PaymentHistoryPaginationModel?,
      filters: identical(filters, _paymentHistoryUnset)
          ? this.filters
          : filters as PaymentHistoryFiltersModel?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _paymentHistoryUnset)
          ? this.errorMessage
          : errorMessage as String?,
      actionType: actionType ?? this.actionType,
    );
  }

  bool get isFetchingHistory =>
      isLoading && actionType == PaymentHistoryActionType.fetchingHistory;
}

enum PaymentHistoryActionType { idle, fetchingHistory }
