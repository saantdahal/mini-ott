import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:miniott/app/routes/router_configuration.dart';
import 'package:miniott/core/utils/responsive_query.dart';
import 'package:miniott/features/content_catalog/di/content_catalog_di.dart';

import '../../domain/entities/search_result.dart';
import '../providers/search_providers.dart';
import '../widgets/search_result_card.dart';
import '../../../../app/flavor/app_flavor.dart';
import '../widgets/search_widgets.dart';
import '../../../coins/presentation/providers/coin_providers.dart';

const Map<String, String> _contentTypeChoices = {
  'movie': 'Movie',
  'series': 'Series',
  'short': 'Short',
};

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String? _contentTypeFilter;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(coinNotifierProvider.notifier).fetchWallet();
    });
  }

  List<SearchResult> _applyContentType(List<SearchResult> list) {
    if (_contentTypeFilter == null) return list;
    final k = _contentTypeFilter!.toLowerCase();
    return list.where((e) => e.contentType.toLowerCase() == k).toList();
  }

  TrendingChipVariant _chipVariant(int i) {
    switch (i % 3) {
      case 0:
        return TrendingChipVariant.purple;
      case 1:
        return TrendingChipVariant.gold;
      default:
        return TrendingChipVariant.muted;
    }
  }

  void _openContentTypeSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Content type',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                ListTile(
                  title: Text(
                    'All types',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                  trailing: _contentTypeFilter == null
                      ? Icon(
                          Icons.check_rounded,
                          color: colorScheme.primary,
                          size: 22.sp,
                        )
                      : null,
                  onTap: () {
                    setState(() => _contentTypeFilter = null);
                    Navigator.pop(ctx);
                  },
                ),
                ..._contentTypeChoices.entries.map(
                  (e) => ListTile(
                    title: Text(
                      e.value,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                    trailing: _contentTypeFilter == e.key
                        ? Icon(
                            Icons.check_rounded,
                            color: colorScheme.primary,
                            size: 22.sp,
                          )
                        : null,
                    onTap: () {
                      setState(() => _contentTypeFilter = e.key);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final genresAsync = ref.watch(genresListProvider);
    final walletBalance = ref.watch(
      coinNotifierProvider.select((state) => state.wallet?.balanceCoins ?? 0),
    );
    final screen = ScreenHelper(context);
    final hPad = screen.paddingAllEdgeInsets;
    final visible = _applyContentType(searchState.searchResults);
    final trending = searchState.trendingSearches;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8.h, hPad, 0),
              child: Row(
                children: [
                  Text(
                    AppFlavorConfig.appName,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: screen.isMobile ? 26.sp : 28.sp,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20.r),
                    child: InkWell(
                      onTap: () => context.push(AppRoutes.coins),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.coins,
                              size: 14.sp,
                              color: colorScheme.tertiary,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '$walletBalance',
                              style: TextStyle(
                                color: colorScheme.surfaceBright,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SearchBar(
              darkStyle: true,
              onChanged: (v) {
                ref
                    .read(searchNotifierProvider.notifier)
                    .searchContent(v.trim());
              },
              onClear: () {
                ref.read(searchNotifierProvider.notifier).clearSearch();
              },
              contentTypeFilterActive: _contentTypeFilter != null,
              onOpenContentTypeFilter: () => _openContentTypeSheet(context),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final innerW = constraints.maxWidth;
                  final cellW = (innerW - hPad * 2 - 12.w) / 2;
                  final mainExtent = cellW * 3 / 2 + 68.h;

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(hPad, 8.h, hPad, 0),
                          child: Text(
                            'Trending Searches',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 44.h,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            scrollDirection: Axis.horizontal,
                            itemCount: trending.length,
                            separatorBuilder: (_, i) => SizedBox(width: 10.w),
                            itemBuilder: (context, i) {
                              final tag = trending[i];
                              return TrendingSearchChip(
                                label: tag,
                                variant: _chipVariant(i),
                                onTap: () {
                                  ref
                                      .read(searchNotifierProvider.notifier)
                                      .searchContent(tag);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 44.h,
                          child: genresAsync.when(
                            data: (genres) {
                              return ListView.separated(
                                padding: EdgeInsets.symmetric(horizontal: hPad),
                                scrollDirection: Axis.horizontal,
                                itemCount: genres.length + 1,
                                separatorBuilder: (_, i) =>
                                    SizedBox(width: 10.w),
                                itemBuilder: (context, i) {
                                  if (i == 0) {
                                    return GenreFilterChip(
                                      genre: 'All',
                                      isSelected:
                                          searchState.selectedGenreId == null,
                                      onTap: () => ref
                                          .read(searchNotifierProvider.notifier)
                                          .filterByGenreId(null, label: 'All'),
                                    );
                                  }
                                  final g = genres[i - 1];
                                  return GenreFilterChip(
                                    genre: g.name,
                                    isSelected:
                                        searchState.selectedGenreId == g.id,
                                    onTap: () => ref
                                        .read(searchNotifierProvider.notifier)
                                        .filterByGenreId(g.id, label: g.name),
                                  );
                                },
                              );
                            },
                            loading: () => ListView(
                              padding: EdgeInsets.symmetric(horizontal: hPad),
                              scrollDirection: Axis.horizontal,
                              children: [
                                GenreFilterChip(
                                  genre: 'All',
                                  isSelected: true,
                                  onTap: () {},
                                ),
                              ],
                            ),
                            error: (_, _) => ListView(
                              padding: EdgeInsets.symmetric(horizontal: hPad),
                              scrollDirection: Axis.horizontal,
                              children: [
                                GenreFilterChip(
                                  genre: 'All',
                                  isSelected:
                                      searchState.selectedGenreId == null,
                                  onTap: () => ref
                                      .read(searchNotifierProvider.notifier)
                                      .filterByGenreId(null, label: 'All'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                      if (visible.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Center(
                              child: Text(
                                searchState.isSearchLoading ||
                                        searchState.isCategoryFilterLoading
                                    ? 'Loading…'
                                    : 'No titles in this filter',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 100.h),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisExtent: mainExtent,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 16.h,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return SearchResultCard(
                                result: visible[index],
                                onTap: () => context.push(
                                  AppRoutes.contentDetailPath(
                                    visible[index].id,
                                  ),
                                ),
                              );
                            }, childCount: visible.length),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
