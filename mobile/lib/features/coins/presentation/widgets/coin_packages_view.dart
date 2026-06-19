import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../../domain/entities/coin_package.dart';
import '../providers/coin_providers.dart';
import 'coin_package_card.dart';

enum _CoinPackFilter { all, popular, recommended }

class CoinPackagesView extends ConsumerStatefulWidget {
  final CoinState coinState;
  final ScreenHelper screen;

  const CoinPackagesView({
    super.key,
    required this.coinState,
    required this.screen,
  });

  @override
  ConsumerState<CoinPackagesView> createState() => _CoinPackagesViewState();
}

class _CoinPackagesViewState extends ConsumerState<CoinPackagesView> {
  _CoinPackFilter _filter = _CoinPackFilter.all;

  List<CoinPackage> _sortedAll(List<CoinPackage> raw) {
    final list = [...raw]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  List<CoinPackage> _visible(
    List<CoinPackage> sorted,
    _CoinPackFilter filter,
  ) {
    switch (filter) {
      case _CoinPackFilter.all:
        return sorted;
      case _CoinPackFilter.popular:
        return sorted.where((p) => p.isPopular).toList();
      case _CoinPackFilter.recommended:
        return sorted.where((p) => !p.isPopular && p.bonusCoins > 0).toList();
    }
  }

  void _setFilter(_CoinPackFilter next) {
    final sorted = _sortedAll(widget.coinState.coinPackages);
    final visible = _visible(sorted, next);
    final id = widget.coinState.selectedPackageId;
    if (id != null && !visible.any((p) => p.id == id)) {
      ref.read(coinNotifierProvider.notifier).clearCoinPackageSelection();
    }
    setState(() => _filter = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final packages = widget.coinState.coinPackages;
    final screen = widget.screen;
    final coinState = widget.coinState;

    if (packages.isEmpty) {
      return _EmptyPackages(screen: screen);
    }

    final sorted = _sortedAll(packages);
    final visible = _visible(sorted, _filter);
    final textScaler = MediaQuery.textScalerOf(context);
    final columns = screen.coinPackageGridColumns;
    final spacing = screen.spacing * 0.65;
    final mainExtent = screen.coinPackageGridMainExtentScaled(textScaler);

    final nAll = sorted.length;
    final nPop = sorted.where((p) => p.isPopular).length;
    final nRec =
        sorted.where((p) => !p.isPopular && p.bonusCoins > 0).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Buy coins',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: screen.isMobile ? 20.sp : 22.sp,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Pick a pack to top up your wallet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: screen.isMobile ? 13.sp : 14.sp,
          ),
        ),
        SizedBox(height: 14.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                screen: screen,
                selected: _filter == _CoinPackFilter.all,
                label: 'All',
                count: nAll,
                onTap: () => _setFilter(_CoinPackFilter.all),
              ),
              SizedBox(width: 8.w),
              _FilterChip(
                screen: screen,
                selected: _filter == _CoinPackFilter.popular,
                label: 'Popular',
                count: nPop,
                onTap: () => _setFilter(_CoinPackFilter.popular),
              ),
              SizedBox(width: 8.w),
              _FilterChip(
                screen: screen,
                selected: _filter == _CoinPackFilter.recommended,
                label: 'Recommended',
                count: nRec,
                onTap: () => _setFilter(_CoinPackFilter.recommended),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        if (visible.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 28.h),
            child: Center(
              child: Text(
                _filter == _CoinPackFilter.popular
                    ? 'No popular packages'
                    : _filter == _CoinPackFilter.recommended
                    ? 'No recommended packages'
                    : 'No packages',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              mainAxisExtent: mainExtent,
            ),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final package = visible[index];
              final isSelected =
                  coinState.selectedPackageId == package.id;
              return CoinPackageCard(
                package: package,
                isSelected: isSelected,
                onTap: () {
                  ref
                      .read(coinNotifierProvider.notifier)
                      .selectCoinPackage(package.id);
                },
              );
            },
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final ScreenHelper screen;
  final bool selected;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.screen,
    required this.selected,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = BorderRadius.circular(999);
    return Material(
      color: selected
          ? cs.primary
          : cs.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: selected
                ? null
                : Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: screen.isMobile ? 13.sp : 14.sp,
                  color: selected ? cs.onPrimary : cs.onSurface,
                ),
              ),
              if (count >= 0) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.onPrimary.withValues(alpha: 0.18)
                        : cs.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: screen.isMobile ? 11.sp : 12.sp,
                      color: selected
                          ? cs.onPrimary
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPackages extends StatelessWidget {
  final ScreenHelper screen;

  const _EmptyPackages({required this.screen});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screen.spacing * 2),
        child: Text(
          'No coin packages available',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
