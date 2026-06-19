import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di.dart';
import '../../data/datasources/payment_history_remote_data_source.dart';
import 'payment_history_notifier.dart';
import 'payment_history_state.dart';

final paymentHistoryRemoteDataSourceProvider =
    Provider<PaymentHistoryRemoteDataSource>((ref) {
      return getIt<PaymentHistoryRemoteDataSource>();
    });

final paymentHistoryNotifierProvider =
    NotifierProvider<PaymentHistoryNotifier, PaymentHistoryState>(
      PaymentHistoryNotifier.new,
    );
