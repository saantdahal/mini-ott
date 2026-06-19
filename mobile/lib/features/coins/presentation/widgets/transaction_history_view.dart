import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../providers/coin_providers.dart';
import 'transaction_item.dart';

/// Transaction history view widget
class TransactionHistoryView extends StatelessWidget {
  final CoinState coinState;
  final ScreenHelper screen;

  const TransactionHistoryView({
    super.key,
    required this.coinState,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    if (coinState.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: screen.spacing * 1.5),
          child: Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction History',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: screen.isMobile ? 18.sp : 20.sp,
          ),
        ),
        SizedBox(height: screen.spacing * 0.75),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: coinState.transactions.length,
          separatorBuilder: (_, _) => SizedBox(height: screen.spacing * 0.5),
          itemBuilder: (context, index) {
            final transaction = coinState.transactions[index];
            return TransactionItem(
              type: transaction.type,
              amount: transaction.amount,
              status: transaction.status,
              date: transaction.createdAt,
              description: transaction.description,
            );
          },
        ),
      ],
    );
  }
}
