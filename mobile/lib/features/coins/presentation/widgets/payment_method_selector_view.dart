import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../providers/coin_providers.dart';
import 'payment_method_selector.dart';

/// Payment method selector view widget
class PaymentMethodSelectorView extends ConsumerWidget {
  final CoinState coinState;
  final ScreenHelper screen;

  const PaymentMethodSelectorView({
    super.key,
    required this.coinState,
    required this.screen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: screen.isMobile ? 18.sp : 20.sp,
          ),
        ),
        SizedBox(height: screen.spacing * 0.75),
        PaymentMethodSelector(
          selectedMethod: coinState.selectedPaymentMethod ?? '',
          onMethodSelected: (method) {
            ref.read(coinNotifierProvider.notifier).selectPaymentMethod(method);
          },
        ),
      ],
    );
  }
}
