import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../../domain/entities/search_result.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  String _metaLine() {
    final g = result.genres.take(2).join(' • ');
    return g.isEmpty ? result.duration : '$g • ${result.duration}';
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final colorScheme = Theme.of(context).colorScheme;
    final label =
        result.overlayLabel ??
        (result.isTrendingTag
            ? 'TRENDING'
            : (result.isPremiumTag ? '4K ULTRA' : null));

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: result.posterUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 200),
                    placeholder: (context, _) => ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, _, _) => ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.movie_outlined,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ),
                  if (label != null && label.isNotEmpty)
                    Positioned(
                      left: 8.w,
                      bottom: 8.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.scrim.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 9.sp,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  if (result.showYellowCorner)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 16.sp,
                          color: colorScheme.onTertiary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Flexible(
            child: Text(
              result.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: screen.isMobile ? 13.sp : 14.sp,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Flexible(
            child: Text(
              _metaLine(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
