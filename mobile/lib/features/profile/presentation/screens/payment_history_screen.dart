import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/back_button.dart';
import '../providers/payment_history_providers.dart';
import '../widgets/payment_history_item.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _status = 'completed';
  String? _gateway;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentHistory();
    });
  }

  Future<void> _loadPaymentHistory({int page = 1}) {
    return ref
        .read(paymentHistoryNotifierProvider.notifier)
        .loadPaymentHistory(
          page: page,
          limit: 10,
          fromDate: _fromDate,
          toDate: _toDate,
          status: _status,
          gateway: _gateway,
        );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now,
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
      helpText: 'Filter payment history by date range',
    );

    if (pickedRange == null) {
      return;
    }

    setState(() {
      _fromDate = pickedRange.start;
      _toDate = pickedRange.end;
    });

    await _loadPaymentHistory();
  }

  Future<void> _clearFilters() async {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _status = 'completed';
      _gateway = null;
    });

    await _loadPaymentHistory();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentHistoryNotifierProvider);
    final screen = ScreenHelper(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading && state.items.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Payment History'),
          leading: CustomIconButton(icon: Icons.arrow_back_ios_rounded),
        ),
        body: const Center(child: AppLoader()),
      );
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Payment History'),
          leading: CustomIconButton(icon: Icons.arrow_back_ios_rounded),
        ),
        body: Center(
          child: AppErrorState(
            message: state.errorMessage ?? 'Failed to load payment history',
            onRetry: () {
              _loadPaymentHistory();
            },
          ),
        ),
      );
    }

    final items = state.items;
    final pagination = state.pagination;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Payment History'),
        leading: CustomIconButton(icon: Icons.arrow_back_ios_rounded),
      ),
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: () {
          return _loadPaymentHistory();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screen.paddingAllEdgeInsets,
            vertical: 16.h,
          ),
          children: [
            _FilterCard(
              fromDate: _fromDate,
              toDate: _toDate,
              status: _status,
              gateway: _gateway,
              onPickDateRange: _pickDateRange,
              onClearFilters: _clearFilters,
            ),
            SizedBox(height: 16.h),
            _SummaryCard(
              total: pagination?.total ?? items.length,
              page: pagination?.page ?? 1,
              totalPages: pagination?.totalPages ?? 1,
            ),
            SizedBox(height: 16.h),
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 40.h),
                child: Center(
                  child: Text(
                    'No payment history available yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(items.length, (index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == items.length - 1 ? 0 : 12.h,
                  ),
                  child: PaymentHistoryItem(item: item),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.gateway,
    required this.onPickDateRange,
    required this.onClearFilters,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final String status;
  final String? gateway;
  final VoidCallback onPickDateRange;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasDateRange = fromDate != null && toDate != null;

    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18.sp,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text('Clear'),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            InkWell(
              onTap: onPickDateRange,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range_rounded,
                      size: 18.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        hasDateRange
                            ? '${_formatDate(fromDate!)}  →  ${_formatDate(toDate!)}'
                            : 'Tap to choose a date range',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasDateRange
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _FilterChip(
                  label: 'Completed',
                  selected: status == 'completed',
                ),
                _FilterChip(label: 'Khalti', selected: gateway == 'khalti'),
                _FilterChip(label: 'eSewa', selected: gateway == 'esewa'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$month/$day/${local.year}';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.page,
    required this.totalPages,
  });

  final int total;
  final int page;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAYMENT HISTORY',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withValues(alpha: 0.78),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '$total completed payments',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Page $page of $totalPages',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withValues(alpha: 0.78),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: colorScheme.onPrimary,
              size: 26.sp,
            ),
          ),
        ],
      ),
    );
  }
}
