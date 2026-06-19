import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/router_configuration.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../home/presentation/widgets/content_grid_card.dart';
import '../notifiers/category_content_notifier.dart';

class CategoryContentScreen extends ConsumerStatefulWidget {
  const CategoryContentScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.categoryDescription,
  });

  final String categoryId;
  final String categoryName;
  final String? categoryDescription;

  @override
  ConsumerState<CategoryContentScreen> createState() =>
      _CategoryContentScreenState();
}

class _CategoryContentScreenState extends ConsumerState<CategoryContentScreen> {
  final ScrollController _scrollController = ScrollController();

  /// Pixels from the bottom at which we trigger the next page load.
  static const double _loadMoreThreshold = 320;

  late final CategoryContentArgs _args = CategoryContentArgs(
    categoryId: widget.categoryId,
    name: widget.categoryName,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(categoryContentNotifierProvider(_args).notifier)
          .loadFirstPageIfNeeded();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      ref.read(categoryContentNotifierProvider(_args).notifier).loadMore();
    }
  }

  Future<void> _refresh() {
    return ref
        .read(categoryContentNotifierProvider(_args).notifier)
        .refresh();
  }

  int _gridColumns(double width) {
    if (width >= 1100) return 5;
    if (width >= 850) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryContentNotifierProvider(_args));
    final colorScheme = Theme.of(context).colorScheme;
    final isFirstLoad = state.isLoading && state.items.isEmpty;
    final hasItems = state.items.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: Text(
          widget.categoryName,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Builder(
          builder: (_) {
            if (isFirstLoad) {
              return const Center(child: AppLoader());
            }
            if (!hasItems && state.errorMessage != null) {
              return AppErrorState(
                message: state.errorMessage!,
                onRetry: _refresh,
              );
            }
            if (!hasItems) {
              return _EmptyState(
                description: widget.categoryDescription,
                onRetry: _refresh,
              );
            }

            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: _refresh,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cols = _gridColumns(constraints.maxWidth);
                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (widget.categoryDescription != null &&
                          widget.categoryDescription!.isNotEmpty)
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            16.w,
                            12.h,
                            16.w,
                            8.h,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              widget.categoryDescription!,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13.sp,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 9 / 14,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final c = state.items[index];
                              return ContentGridCard(
                                content: c,
                                showFreeTag: c.accessType == 'free',
                                onTap: () => context.push(
                                  AppRoutes.contentDetailPath(c.id),
                                ),
                              );
                            },
                            childCount: state.items.length,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _GridFooter(
                          isLoadingMore: state.isLoadingMore,
                          hasMore: state.hasMore,
                          errorMessage: state.errorMessage,
                          onRetry: () => ref
                              .read(
                                categoryContentNotifierProvider(_args).notifier,
                              )
                              .loadMore(),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GridFooter extends StatelessWidget {
  const _GridFooter({
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        child: Center(
          child: SizedBox(
            width: 22.w,
            height: 22.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
        child: Column(
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 10.h),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        child: Center(
          child: Text(
            "You've reached the end",
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
        ),
      );
    }

    return SizedBox(height: 12.h);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.description, required this.onRetry});

  final String? description;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 96.h),
          Icon(
            Icons.category_outlined,
            size: 56.sp,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 12.h),
          Text(
            'No titles yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              description?.isNotEmpty == true
                  ? description!
                  : 'Pull down to refresh once new titles arrive.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
