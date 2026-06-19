import 'package:flutter/material.dart';
import 'package:flutter_easy_messages/flutter_easy_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';

import '../../../../core/utils/responsive_query.dart';
import '../../../payment/esewa/presentation/screens/esewa_webview_checkout_screen.dart';
import '../../../payment/khalti/presentation/screens/khalti_checkout_screen.dart';
import '../../domain/entities/coin_package.dart';
import '../providers/coin_providers.dart';
import '../widgets/coin_widgets.dart';

class CoinScreen extends ConsumerStatefulWidget {
  const CoinScreen({super.key});

  @override
  ConsumerState<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends ConsumerState<CoinScreen> {
  final ScrollController _scroll = ScrollController();
  double _scrollOffset = 0;
  // Re-entry guard so the listener doesn't try to open a second sheet while
  // the first one is still up (or while we're navigating to the gateway).
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(coinNotifierProvider.notifier).initializeData();
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final next = _scroll.offset.clamp(0.0, 80.0);
    if ((next - _scrollOffset).abs() > 0.5) {
      setState(() => _scrollOffset = next);
    }
  }

  CoinPackage? _findSelected(CoinState state) {
    final id = state.selectedPackageId;
    if (id == null) return null;
    for (final p in state.coinPackages) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> _refresh() async {
    final notifier = ref.read(coinNotifierProvider.notifier);
    await Future.wait<void>([
      notifier.fetchWallet(),
      notifier.fetchTransactionHistory(),
    ]);
  }

  /// Pushes the gateway WebView for the currently-selected package + method
  /// and refetches wallet state on success. Returns whether the purchase
  /// completed so the caller (the checkout sheet) can dismiss itself.
  Future<bool> _runPayment() async {
    final state = ref.read(coinNotifierProvider);
    if (state.isPurchasing) return false;
    if (state.selectedPaymentMethod == null) {
      showAppToast(
        'Please select a payment method',
        context: context,
        messageType: MessageType.warning,
      );
      return false;
    }
    final pkg = _findSelected(state);
    if (pkg == null) return false;
    final method = state.selectedPaymentMethod!;
    bool? ok;
    if (method == 'khalti') {
      ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (ctx) => KhaltiCheckoutScreen(
            packageId: pkg.id,
            price: pkg.price,
            packageName: pkg.title,
          ),
        ),
      );
    } else if (method == 'esewa') {
      ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (ctx) => EsewaWebviewCheckoutScreen(
            packageId: pkg.id,
            price: pkg.price,
            productName: pkg.title,
          ),
        ),
      );
    } else {
      return false;
    }
    if (ok == true && mounted) {
      await ref.read(coinNotifierProvider.notifier).fetchWallet();
      await ref.read(coinNotifierProvider.notifier).fetchTransactionHistory();
      if (mounted) {
        showAppToast(
          'Payment successful',
          context: context,
          messageType: MessageType.success,
        );
      }
      return true;
    }
    return false;
  }

  Future<void> _openCheckoutSheet() async {
    if (_sheetOpen) return;
    final pkg = _findSelected(ref.read(coinNotifierProvider));
    if (pkg == null) return;
    _sheetOpen = true;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (sheetCtx) => _CheckoutSheet(
          package: pkg,
          onConfirmPay: () async {
            final ok = await _runPayment();
            if (ok && sheetCtx.mounted) {
              Navigator.of(sheetCtx).pop();
            }
          },
        ),
      );
    } finally {
      _sheetOpen = false;
      // Always clear the selection on close. If the user re-taps the same
      // pack, this lets the listener re-fire and re-open the sheet.
      if (mounted) {
        ref.read(coinNotifierProvider.notifier).clearCoinPackageSelection();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Open the checkout sheet whenever a package becomes selected. Clearing
    // the selection (on sheet dismiss) sets next to null and is a no-op here.
    ref.listen<String?>(
      coinNotifierProvider.select((s) => s.selectedPackageId),
      (prev, next) {
        if (next != null && next != prev) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _openCheckoutSheet();
          });
        }
      },
    );

    final coinState = ref.watch(coinNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final screen = ScreenHelper(context);
    // Skeleton stays up for the entire cold start: from the first frame
    // (before any fetch fires) through both the wallet and packages loads,
    // including the microtask gap between them. Flips off the moment
    // `initializeData` resolves, regardless of whether either call errored.
    final isFirstLoad = !coinState.isFirstLoadComplete;
    final hasFatalError = coinState.isFirstLoadComplete &&
        coinState.errorMessage != null &&
        coinState.coinPackages.isEmpty;
    final balance = coinState.wallet?.balanceCoins ?? 0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      body: hasFatalError
          ? SafeArea(
              child: _ErrorView(
                message: coinState.errorMessage ?? 'An unknown error occurred',
                onRetry: () => ref.invalidate(coinNotifierProvider),
              ),
            )
          : MirrorSkeleton(
              isLoading: isFirstLoad,
              child: RefreshIndicator(
                color: colorScheme.primary,
                onRefresh: _refresh,
                child: _buildContent(
                  context,
                  coinState,
                  screen,
                  balance,
                  isFirstLoad,
                ),
              ),
            ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CoinState coinState,
    ScreenHelper screen,
    int balance,
    bool isFirstLoad,
  ) {
    final contentMaxWidth = screen.isDesktop ? 960.0 : double.infinity;
    final hPad = screen.paddingAllEdgeInsets;

    return ListView(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _BalanceHero(balance: balance),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 24.h, hPad, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cold start: render placeholders so MirrorSkeleton has
                  // a packages grid and transaction list to mirror. Without
                  // these the body just renders empty-state text and the
                  // shimmer would only cover the hero.
                  if (isFirstLoad)
                    ..._buildSkeletonBody(context, screen)
                  else ...[
                    CoinPackagesView(coinState: coinState, screen: screen),
                    SizedBox(height: 28.h),
                    TransactionHistoryView(
                      coinState: coinState,
                      screen: screen,
                    ),
                  ],
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Layout-shaped placeholder for the cold-start skeleton: section header
  /// + filter chips + a packages grid + a transaction-history list. Every
  /// container/text becomes a bone at paint time inside `MirrorSkeleton`.
  List<Widget> _buildSkeletonBody(
    BuildContext context,
    ScreenHelper screen,
  ) {
    final cs = Theme.of(context).colorScheme;
    final boneColor = cs.surfaceContainerHighest;

    Widget bone({double? width, double? height, double radius = 8}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: boneColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    final textScaler = MediaQuery.textScalerOf(context);
    final cardH = screen.coinPackageGridMainExtentScaled(textScaler);
    final columns = screen.coinPackageGridColumns;
    final spacing = screen.spacing * 0.65;

    Widget packageCardPlaceholder() => Container(
      height: cardH,
      decoration: BoxDecoration(
        color: boneColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
    );

    Widget txItemPlaceholder() => Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          bone(width: 40.r, height: 40.r, radius: 999),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bone(width: 180.w, height: 14.h),
                SizedBox(height: 6.h),
                bone(width: 100.w, height: 11.h),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          bone(width: 60.w, height: 14.h),
        ],
      ),
    );

    return [
      // "Buy coins" + subtitle
      Align(
        alignment: Alignment.centerLeft,
        child: bone(width: 140.w, height: 22.h),
      ),
      SizedBox(height: 8.h),
      Align(
        alignment: Alignment.centerLeft,
        child: bone(width: 220.w, height: 13.h),
      ),
      SizedBox(height: 14.h),
      // Filter chips row
      Row(
        children: [
          bone(width: 64.w, height: 30.h, radius: 999),
          SizedBox(width: 8.w),
          bone(width: 92.w, height: 30.h, radius: 999),
          SizedBox(width: 8.w),
          bone(width: 116.w, height: 30.h, radius: 999),
        ],
      ),
      SizedBox(height: 16.h),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          mainAxisExtent: cardH,
        ),
        itemCount: columns * 2,
        itemBuilder: (_, _) => packageCardPlaceholder(),
      ),
      SizedBox(height: 32.h),
      // Transaction history header + items
      Align(
        alignment: Alignment.centerLeft,
        child: bone(width: 170.w, height: 18.h),
      ),
      SizedBox(height: 12.h),
      txItemPlaceholder(),
      txItemPlaceholder(),
      txItemPlaceholder(),
      txItemPlaceholder(),
    ];
  }
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top + kToolbarHeight + 8.h;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, Color.lerp(cs.primary, Colors.black, 0.35)!],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -40,
            right: -50,
            child: _Orb(size: 220, color: Colors.white, opacity: 0.10),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: _Orb(size: 180, color: Colors.white, opacity: 0.06),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, topPad, 24.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR BALANCE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Icon(
                        Icons.monetization_on_rounded,
                        color: Colors.white,
                        size: 26.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '$balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 56.sp,
                            height: 1.0,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        'coins',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _HeroPill(
                  icon: Icons.card_giftcard_rounded,
                  label: '100 coins = 1 voucher',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color, required this.opacity});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal sheet that consolidates the entire purchase confirmation: shows
/// the picked package, lets the user choose a payment method, and runs
/// the payment when confirmed. Reads `selectedPaymentMethod` + `isPurchasing`
/// reactively so the Pay button enables/disables without prop drilling.
class _CheckoutSheet extends ConsumerWidget {
  const _CheckoutSheet({required this.package, required this.onConfirmPay});

  final CoinPackage package;
  final Future<void> Function() onConfirmPay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final selectedMethod = ref.watch(
      coinNotifierProvider.select((s) => s.selectedPaymentMethod),
    );
    final isPurchasing = ref.watch(
      coinNotifierProvider.select((s) => s.isPurchasing),
    );
    final canPay = selectedMethod != null && !isPurchasing;
    final totalCoins = package.coins + package.bonusCoins;
    final priceLabel =
        '${package.currency} ${package.price.toStringAsFixed(0)}';

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtl,
                padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Confirm purchase',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20.sp,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _PackageSummaryCard(package: package, totalCoins: totalCoins),
                  SizedBox(height: 18.h),
                  _TotalRow(label: 'Total', value: priceLabel),
                  SizedBox(height: 18.h),
                  Divider(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                    height: 1,
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Pay with',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.sp,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  PaymentMethodSelector(
                    selectedMethod: selectedMethod ?? '',
                    onMethodSelected: (m) => ref
                        .read(coinNotifierProvider.notifier)
                        .selectPaymentMethod(m),
                  ),
                  if (selectedMethod == null) ...[
                    SizedBox(height: 10.h),
                    Text(
                      'Select a payment method to continue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            ),
            // Pay CTA pinned at the bottom of the sheet.
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  top: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                20.w,
                14.h,
                20.w,
                14.h + MediaQuery.of(context).padding.bottom * 0.0,
              ),
              child: SizedBox(
                height: 54.h,
                child: FilledButton(
                  onPressed: canPay ? onConfirmPay : null,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: isPurchasing
                      ? SizedBox(
                          width: 22.w,
                          height: 22.h,
                          child: CircularProgressIndicator(
                            color: cs.onPrimary,
                            strokeWidth: 2.6,
                          ),
                        )
                      : Text(
                          'Pay $priceLabel',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16.sp,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageSummaryCard extends StatelessWidget {
  const _PackageSummaryCard({required this.package, required this.totalCoins});

  final CoinPackage package;
  final int totalCoins;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.55),
            cs.primaryContainer.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.15),
              border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
            ),
            child: Icon(
              Icons.monetization_on_rounded,
              color: cs.primary,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      '$totalCoins coins',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                    if (package.bonusCoins > 0) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: cs.tertiary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+${package.bonusCoins} bonus',
                          style: TextStyle(
                            color: cs.tertiary,
                            fontWeight: FontWeight.w800,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 24.sp,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56.sp, color: cs.error),
            SizedBox(height: 16.h),
            Text(
              "Couldn't load coins",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 18.h),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
