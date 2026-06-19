import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../../domain/entities/content_entity.dart';
import '../providers/home_ui_providers.dart';

class FeaturedContentCard extends ConsumerWidget {
  const FeaturedContentCard({
    super.key,
    required this.content,
    this.onOpenDetail,
    this.onWatchNow,
    this.onShare,
  });

  final ContentEntity content;
  final VoidCallback? onOpenDetail;
  final VoidCallback? onWatchNow;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ScreenHelper(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final watchGradient = LinearGradient(
      colors: [colorScheme.primary, colorScheme.primaryContainer],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final mq = MediaQuery.sizeOf(context);
    final heroH = (mq.height * 0.46).clamp(268.0, 440.0);
    final url = content.posterUrl.isNotEmpty
        ? content.posterUrl
        : content.thumbnailUrl;
    final category = content.contentType.trim().isEmpty
        ? 'FEATURED'
        : content.contentType.toUpperCase();
    final saved = ref.watch(savedContentIdsProvider);
    final isSaved = saved.contains(content.id);

    Widget hero = Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.fill,
          fadeInDuration: const Duration(milliseconds: 280),
          placeholder: (context, _) => ColoredBox(
            color: colorScheme.surfaceContainerHighest,
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          errorWidget: (context, _, _) => ColoredBox(
            color: colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.movie_outlined,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.92),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ],
    );

    if (onOpenDetail != null) {
      hero = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onOpenDetail,
        child: hero,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: SizedBox(
        height: heroH,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            hero,
            Positioned(
              left: 18.w,
              right: 18.w,
              bottom: 20.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: screen.isMobile ? 11.sp : 12.sp,
                      letterSpacing: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    content.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: screen.isMobile ? 26.sp : 30.sp,
                      height: 1.05,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    content.genres.take(4).join(' • '),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: screen.isMobile ? 13.sp : 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onWatchNow ?? () {},
                            borderRadius: BorderRadius.circular(14.r),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: watchGradient,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: colorScheme.onPrimary,
                                      size: 26.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'Watch Now',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: screen.isMobile
                                            ? 14.sp
                                            : 15.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      _squareIconButton(
                        context: context,
                        icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_rounded,
                        onTap: () {
                          ref.read(savedContentIdsProvider.notifier).toggle(content.id);
                        },
                      ),
                      SizedBox(width: 10.w),
                      _squareIconButton(
                        context: context,
                        icon: Icons.share_rounded,
                        onTap: onShare ?? () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _squareIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: SizedBox(
          width: 52.w,
          height: 52.w,
          child: Icon(icon, color: colorScheme.onSurface, size: 22.sp),
        ),
      ),
    );
  }
}
