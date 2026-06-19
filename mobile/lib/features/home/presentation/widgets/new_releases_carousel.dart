import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/content_entity.dart';

class NewReleasesCarousel extends StatefulWidget {
  const NewReleasesCarousel({
    super.key,
    required this.items,
    required this.onTap,
  });

  final List<ContentEntity> items;
  final void Function(ContentEntity content) onTap;

  @override
  State<NewReleasesCarousel> createState() => _NewReleasesCarouselState();
}

class _NewReleasesCarouselState extends State<NewReleasesCarousel> {
  static const Duration _autoAdvance = Duration(seconds: 4);
  static const Duration _slideDuration = Duration(milliseconds: 650);
  // Hero-dominant: focused card takes ~85% of width, leaving only narrow
  // peeks of neighbors so the screen doesn't feel cluttered.
  static const double _viewportFraction = 0.85;
  // Seed page far from zero so users can swipe both directions for a long
  // time before hitting the bounds of the unbounded itemBuilder cycle.
  static const int _initialPage = 10000;

  late final PageController _controller;
  Timer? _timer;
  double _page = _initialPage.toDouble();

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: _initialPage,
      viewportFraction: _viewportFraction,
    );
    _controller.addListener(_onScroll);
    _startAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant NewReleasesCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final page = _controller.page;
    if (page == null) return;
    setState(() => _page = page);
  }

  void _startAutoAdvance() {
    _timer?.cancel();
    if (widget.items.length <= 1) return;
    _timer = Timer.periodic(_autoAdvance, (_) {
      if (!mounted || !_controller.hasClients) return;
      final current = _controller.page ?? _page;
      _controller.animateToPage(
        current.round() + 1,
        duration: _slideDuration,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final slotW = constraints.maxWidth * _viewportFraction;
        final imageH = slotW * 9 / 16;
        // Breathing room for the lifted focused card + soft halo shadow.
        final totalH = imageH + 44.h;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: totalH,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollStartNotification && n.dragDetails != null) {
                    _timer?.cancel();
                  } else if (n is ScrollEndNotification) {
                    _startAutoAdvance();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = items[index % items.length];
                    final delta = (index - _page).clamp(-1.2, 1.2);
                    final absDelta = delta.abs();
                    final focus = (1 - absDelta).clamp(0.0, 1.0);
                    // Focused card at 1.0, side peeks at ~0.84 — a calm,
                    // modern depth cue without skewing the artwork.
                    final scale = (1 - absDelta * 0.16).clamp(0.78, 1.0);
                    // Slight Z recession + lift on the hero so it floats
                    // above the neighbors. No rotateY — keeps side cards
                    // looking like the same card, just further away.
                    final translateZ = -absDelta * 50.0;
                    final translateY = -6.0 * focus;
                    final opacity = (1 - absDelta * 0.55).clamp(0.35, 1.0);

                    return Center(
                      child: Opacity(
                        opacity: opacity,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0015)
                            ..translateByDouble(
                              0.0,
                              translateY,
                              translateZ,
                              1.0,
                            )
                            ..scaleByDouble(scale, scale, scale, 1),
                          child: _CarouselCard(
                            content: item,
                            width: slotW,
                            imageHeight: imageH,
                            focus: focus,
                            onTap: () => widget.onTap(item),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 10.h),
            _PageDots(
              count: items.length,
              activeIndex: _page.round() % items.length,
            ),
          ],
        );
      },
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          height: 6.h,
          width: isActive ? 18.w : 6.w,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({
    required this.content,
    required this.width,
    required this.imageHeight,
    required this.focus,
    required this.onTap,
  });

  final ContentEntity content;
  final double width;
  final double imageHeight;
  // 0..1 — 1 means this is the centered card.
  final double focus;
  final VoidCallback onTap;

  String get _imageUrl => content.thumbnailUrl.isNotEmpty
      ? content.thumbnailUrl
      : content.posterUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Container(
          height: imageHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              // Subtle ambient — present on every card so they all sit on
              // a plane.
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, 6),
              ),
              // Hero lift — focused card gets a wide, soft halo. Color
              // pulled from theme primary so it feels branded, not muddy.
              if (focus > 0.05)
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.28 * focus),
                  blurRadius: 3 * focus,
                  spreadRadius: 1 * focus,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: _imageUrl,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 220),
                  placeholder: (_, _) =>
                      ColoredBox(color: colorScheme.surfaceContainerHighest),
                  errorWidget: (_, _, _) => ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.movie_outlined,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.78),
                          Colors.black.withValues(alpha: 0.0),
                        ],
                        stops: const [0, 0.55],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 14.h,
                  child: Text(
                    content.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.sp,
                      letterSpacing: -0.3,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
