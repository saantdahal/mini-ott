import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:miniott/app/routes/router_configuration.dart';
import 'package:miniott/core/utils/responsive_query.dart';
import 'package:miniott/shared/widgets/app_error_state.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';
import '../../data/repositories/home_repository_impl.dart'
    show virtualLatestId, virtualUncategorizedId;
import '../../domain/entities/content_entity.dart';
import '../models/content_section.dart';
import '../providers/home_providers.dart';
import '../widgets/home_rail_card.dart';
import '../widgets/new_releases_carousel.dart';
import '../widgets/section_header.dart';
import '../../../../app/flavor/app_flavor.dart';
import '../../../coins/presentation/providers/coin_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).fetchAllContent();
      ref.read(coinNotifierProvider.notifier).fetchWallet();
    });
  }

  double _railCardWidth(double w, double hPad) {
    return ((w - hPad * 2) * 0.72).clamp(200.0, 280.0);
  }

  /// Always show "See All" when a section has at least one title — except
  /// for the synthesized "More Titles" rail of uncategorized content,
  /// which the server cannot paginate (no "no category" filter exists).
  VoidCallback? _seeAllCallback(BuildContext context, ContentSection section) {
    if (section.contents.isEmpty) return null;
    if (section.categoryId == virtualUncategorizedId) return null;
    return () => context.push(
      AppRoutes.categoryBrowsePath(section.categoryId),
      extra: <String, String?>{
        'name': section.categoryName,
        'description': section.categoryDescription,
      },
    );
  }

  double _railListHeight(
    double cardW,
    List<ContentEntity> items,
    HomeRailKind kind,
  ) {
    double h(ContentEntity c) {
      final thumb = cardW * 9 / 16;
      // Title block: 10.h spacer + ~40.h for up-to-2-line title.
      var rest = 10.h + 40.h;
      if (c.cardSubtitle != null && c.cardSubtitle!.isNotEmpty) {
        rest += 18.h;
      }
      return thumb + rest;
    }

    if (items.isEmpty) return cardW * 9 / 16 + 80.h;
    return items.map(h).reduce(math.max);
  }

  /// Layout-shaped placeholder for cold-start skeleton state. Returns a list
  /// of slivers — a hero carousel placeholder followed by two horizontal rail
  /// placeholders, each with a section header. MirrorSkeleton walks this
  /// tree and replaces every container/text with bones, so the user sees a
  /// rich shimmer covering the whole page instead of just the app bar.
  List<Widget> _buildSkeletonSlivers({
    required double w,
    required double cardW,
    required double hPad,
    required ColorScheme cs,
  }) {
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

    Widget sectionHeaderPlaceholder() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bone(width: 160.w, height: 18.h),
            SizedBox(height: 8.h),
            bone(width: 220.w, height: 12.h),
          ],
        ),
      );
    }

    Widget railPlaceholder() {
      final imageH = cardW * 9 / 16;
      final h = imageH + 60.h;
      return SizedBox(
        height: h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(left: hPad, right: hPad * 0.35),
          itemCount: 4,
          itemBuilder: (_, _) => Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: SizedBox(
              width: cardW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bone(height: imageH, radius: 14),
                  SizedBox(height: 10.h),
                  bone(height: 14.h, radius: 4),
                  SizedBox(height: 6.h),
                  bone(width: cardW * 0.6, height: 12.h, radius: 4),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final heroH = (w.clamp(0, 960) * 0.78) * 9 / 16 + 36.h;

    return [
      SliverToBoxAdapter(child: sectionHeaderPlaceholder()),
      SliverToBoxAdapter(child: SizedBox(height: 14.h)),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad * 1.5),
          child: bone(height: heroH, radius: 20),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 28.h)),
      SliverToBoxAdapter(child: sectionHeaderPlaceholder()),
      SliverToBoxAdapter(child: SizedBox(height: 14.h)),
      SliverToBoxAdapter(child: railPlaceholder()),
      SliverToBoxAdapter(child: SizedBox(height: 28.h)),
      SliverToBoxAdapter(child: sectionHeaderPlaceholder()),
      SliverToBoxAdapter(child: SizedBox(height: 14.h)),
      SliverToBoxAdapter(child: railPlaceholder()),
    ];
  }

  Widget _horizontalRail({
    required BuildContext context,
    required double cardW,
    required double listHeight,
    required List<ContentEntity> items,
    required HomeRailKind kind,
    required double hPad,
  }) {
    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: hPad, right: hPad * 0.35),
        itemCount: items.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final c = items[index];
          return SizedBox(
            width: cardW,
            child: HomeRailCard(
              content: c,
              kind: kind,
              onTap: () => context.push(AppRoutes.contentDetailPath(c.id)),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final walletBalance = ref.watch(
      coinNotifierProvider.select((state) => state.wallet?.balanceCoins ?? 0),
    );
    final hasLiveData = homeState.contentSections.isNotEmpty;
    final screen = ScreenHelper(context);

    // Only show skeleton during initial loading. If loading finishes with no
    // content, render the empty state instead of a persistent shimmer.
    final showSkeleton = !hasLiveData && homeState.isLoading;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: MirrorSkeleton(
        isLoading: showSkeleton,
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final hPad = screen.paddingAllEdgeInsets;
              final cardW = _railCardWidth(w, hPad);

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: w.clamp(0, 960)),
                  child: RefreshIndicator(
                    color: colorScheme.primary,
                    onRefresh: () => ref
                        .read(homeNotifierProvider.notifier)
                        .fetchAllContent(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(hPad, 6.h, hPad, 14.h),
                            child: _HomeHeaderDark(
                              screen: screen,
                              walletBalance: walletBalance,
                              onCoinsTap: () => context.push(AppRoutes.coins),
                            ),
                          ),
                        ),
                        // Cold start: render a layout-shaped placeholder so
                        // MirrorSkeleton has rails / a hero / headers to
                        // mirror. Without this the tree only contains the
                        // app bar and the shimmer would only cover that.
                        if (showSkeleton)
                          ..._buildSkeletonSlivers(
                            w: w,
                            cardW: cardW,
                            hPad: hPad,
                            cs: colorScheme,
                          )
                        // Dynamically render content sections based on categories
                        else if (homeState.contentSections.isNotEmpty)
                          ...homeState.contentSections
                              .asMap()
                              .entries
                              .map((entry) {
                                final section = entry.value;
                                final isFirst = entry.key == 0;
                                final isNewReleases =
                                    section.categoryId == virtualLatestId;

                                return [
                                  if (!isFirst)
                                    SliverToBoxAdapter(
                                      child: SizedBox(height: 28.h),
                                    ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: hPad,
                                      ),
                                      child: SectionHeader(
                                        title: section.categoryName,
                                        subtitle: section.categoryDescription,
                                        lightOnDark: true,
                                        onSeeAll: isNewReleases
                                            ? null
                                            : _seeAllCallback(context, section),
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: SizedBox(height: 14.h),
                                  ),
                                  SliverToBoxAdapter(
                                    child: isNewReleases
                                        ? NewReleasesCarousel(
                                            items: section.contents,
                                            onTap: (c) => context.push(
                                              AppRoutes.contentDetailPath(c.id),
                                            ),
                                          )
                                        : _horizontalRail(
                                            context: context,
                                            cardW: cardW,
                                            listHeight: _railListHeight(
                                              cardW,
                                              section.contents,
                                              HomeRailKind.standard,
                                            ),
                                            items: section.contents,
                                            kind: HomeRailKind.standard,
                                            hPad: hPad,
                                          ),
                                  ),
                                ];
                              })
                              .expand((e) => e),
                        // Only surface the error inline when we already have
                        // content (i.e. a refresh failed).
                        if (homeState.errorMessage != null && hasLiveData)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(hPad),
                              child: AppErrorState(
                                message: homeState.errorMessage!,
                                onRetry: () => ref
                                    .read(homeNotifierProvider.notifier)
                                    .fetchAllContent(),
                              ),
                            ),
                          ),
                        if (!homeState.isLoading && !hasLiveData)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: hPad,
                                vertical: 48.h,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.movie_filter_outlined,
                                    size: 56.sp,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'No content available',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Pull down to refresh once new titles are available.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeHeaderDark extends StatelessWidget {
  const _HomeHeaderDark({
    required this.screen,
    required this.walletBalance,
    required this.onCoinsTap,
  });

  final ScreenHelper screen;
  final int walletBalance;
  final VoidCallback onCoinsTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          AppFlavorConfig.appName,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: screen.isMobile ? 22.sp : 24.sp,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                context.go(AppRoutes.notifications);
              },
              icon: Icon(
                Icons.notifications_none_rounded,
                size: 26.sp,
                color: colorScheme.onSurface,
              ),
            ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 4.w),
        Material(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            onTap: onCoinsTap,
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: screen.isMobile ? 13.sp : 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
