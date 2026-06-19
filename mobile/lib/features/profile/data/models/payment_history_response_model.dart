class PaymentHistoryResponseModel {
  const PaymentHistoryResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final PaymentHistoryDataModel data;

  factory PaymentHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final dataJson = Map<String, dynamic>.from(
      json['data'] as Map? ?? const <String, dynamic>{},
    );

    return PaymentHistoryResponseModel(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: PaymentHistoryDataModel.fromJson(dataJson),
    );
  }
}

class PaymentHistoryDataModel {
  const PaymentHistoryDataModel({
    required this.items,
    required this.pagination,
    required this.filters,
  });

  final List<PaymentHistoryItemModel> items;
  final PaymentHistoryPaginationModel pagination;
  final PaymentHistoryFiltersModel? filters;

  factory PaymentHistoryDataModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) => PaymentHistoryItemModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <PaymentHistoryItemModel>[];

    return PaymentHistoryDataModel(
      items: items,
      pagination: PaymentHistoryPaginationModel.fromJson(
        Map<String, dynamic>.from(
          json['pagination'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      filters: json['filters'] is Map
          ? PaymentHistoryFiltersModel.fromJson(
              Map<String, dynamic>.from(json['filters'] as Map),
            )
          : null,
    );
  }
}

class PaymentHistoryItemModel {
  const PaymentHistoryItemModel({
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.gateway,
    required this.gatewayTransactionId,
    required this.gatewayReference,
    required this.paymentFor,
    required this.coinsCredited,
    required this.paidAt,
    required this.createdAt,
    required this.user,
    required this.coinPackage,
  });

  final String paymentId;
  final double amount;
  final String currency;
  final String status;
  final String gateway;
  final String? gatewayTransactionId;
  final String? gatewayReference;
  final String paymentFor;
  final int coinsCredited;
  final DateTime? paidAt;
  final DateTime createdAt;
  final PaymentHistoryUserModel? user;
  final PaymentHistoryCoinPackageModel? coinPackage;

  factory PaymentHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItemModel(
      paymentId: (json['payment_id'] ?? '').toString(),
      amount: _parseDouble(json['amount']),
      currency: (json['currency'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      gateway: (json['gateway'] ?? '').toString(),
      gatewayTransactionId: json['gateway_transaction_id']?.toString(),
      gatewayReference: json['gateway_reference']?.toString(),
      paymentFor: (json['payment_for'] ?? '').toString(),
      coinsCredited: _parseInt(json['coins_credited']),
      paidAt: _parseDateTime(json['paid_at']),
      createdAt:
          _parseDateTime(json['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      user: json['user'] is Map
          ? PaymentHistoryUserModel.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
      coinPackage: json['coin_package'] is Map
          ? PaymentHistoryCoinPackageModel.fromJson(
              Map<String, dynamic>.from(json['coin_package'] as Map),
            )
          : null,
    );
  }
}

class PaymentHistoryUserModel {
  const PaymentHistoryUserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });

  final String userId;
  final String fullName;
  final String email;
  final String? phone;
  final String role;

  factory PaymentHistoryUserModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryUserModel(
      userId: (json['user_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      role: (json['role'] ?? '').toString(),
    );
  }
}

class PaymentHistoryCoinPackageModel {
  const PaymentHistoryCoinPackageModel({
    required this.coinPackageId,
    required this.title,
    required this.coins,
    required this.bonusCoins,
    required this.priceAmount,
  });

  final String coinPackageId;
  final String title;
  final int coins;
  final int bonusCoins;
  final double priceAmount;

  factory PaymentHistoryCoinPackageModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryCoinPackageModel(
      coinPackageId: (json['coin_package_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      coins: _parseInt(json['coins']),
      bonusCoins: _parseInt(json['bonus_coins']),
      priceAmount: _parseDouble(json['price_amount']),
    );
  }
}

class PaymentHistoryPaginationModel {
  const PaymentHistoryPaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory PaymentHistoryPaginationModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryPaginationModel(
      page: _parseInt(json['page'], fallback: 1),
      limit: _parseInt(json['limit'], fallback: 10),
      total: _parseInt(json['total']),
      totalPages: _parseInt(json['total_pages']),
    );
  }
}

class PaymentHistoryFiltersModel {
  const PaymentHistoryFiltersModel({
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.gateway,
    required this.userId,
  });

  final String? fromDate;
  final String? toDate;
  final String? status;
  final String? gateway;
  final String? userId;

  factory PaymentHistoryFiltersModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryFiltersModel(
      fromDate: json['from_date']?.toString(),
      toDate: json['to_date']?.toString(),
      status: json['status']?.toString(),
      gateway: json['gateway']?.toString(),
      userId: json['user_id']?.toString(),
    );
  }
}

double _parseDouble(dynamic value, {double fallback = 0}) {
  if (value is num) {
    return value.toDouble();
  }

  final parsed = double.tryParse(value?.toString() ?? '');
  return parsed ?? fallback;
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _parseDateTime(dynamic value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) {
    return null;
  }

  return DateTime.tryParse(raw);
}
