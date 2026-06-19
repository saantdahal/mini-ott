import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/content_entity.dart';

double _watchingFraction(String progress) {
  final clean = progress.replaceAll('%', '').trim();
  final v = double.tryParse(clean);
  if (v == null) return 0;
  return (v / 100).clamp(0.0, 1.0);
}

class ContentGridCard extends StatelessWidget {
  final ContentEntity content;
  final VoidCallback? onTap;
  final bool showFreeTag;

  const ContentGridCard({
    super.key,
    required this.content,
    this.onTap,
    this.showFreeTag = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = content.posterUrl.isNotEmpty
        ? content.posterUrl
        : content.thumbnailUrl;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.fill,
              fadeInDuration: const Duration(milliseconds: 220),
              placeholder: (context, _) => ColoredBox(
                color: cs.surfaceContainerHighest,
                child: Center(
                  child: SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, _, _) => ColoredBox(
                color: cs.surfaceContainerHighest,
                child: Icon(
                  Icons.movie_outlined,
                  size: 32.sp,
                  color: cs.outline,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.scrim.withValues(alpha: 0.05),
                    cs.scrim.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            if (showFreeTag && content.accessType == 'free')
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: cs.tertiary,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'FREE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onTertiary,
                      fontWeight: FontWeight.w800,
                      fontSize: 9.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            if (content.isWatching)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12.r),
                  ),
                  child: LinearProgressIndicator(
                    value: _watchingFraction(content.watchingProgress),
                    backgroundColor: cs.scrim.withValues(alpha: 0.38),
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                    minHeight: 4.h,
                  ),
                ),
              ),
            Positioned(
              left: 8.w,
              right: 8.w,
              bottom: content.isWatching ? 18.h : 10.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      content.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                        height: 1.15,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black.withValues(alpha: 0.54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
