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

enum HomeRailKind { continueWatching, freeEpisode, standard }

class HomeRailCard extends StatelessWidget {
  const HomeRailCard({
    super.key,
    required this.content,
    required this.kind,
    this.onTap,
  });

  final ContentEntity content;
  final HomeRailKind kind;
  final VoidCallback? onTap;

  String get _imageUrl => content.thumbnailUrl.isNotEmpty
      ? content.thumbnailUrl
      : content.posterUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showProgress =
        kind == HomeRailKind.continueWatching && content.isWatching;
    final showFreeBanner =
        kind == HomeRailKind.freeEpisode && content.accessType == 'free';
    final bannerText = content.freeBannerText ?? '10 FREE EPISODES';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: _imageUrl,
                    fit: BoxFit.fill,
                    fadeInDuration: const Duration(milliseconds: 220),
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
                  if (showFreeBanner)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          bannerText,
                          style: TextStyle(
                            color: colorScheme.onTertiary,
                            fontWeight: FontWeight.w900,
                            fontSize: 9.sp,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  if (content.episodeChip != null &&
                      content.episodeChip!.isNotEmpty)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.scrim.withValues(alpha: 0.62),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                        child: Text(
                          content.episodeChip!,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 9.sp,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  if (showProgress)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: _watchingFraction(content.watchingProgress),
                        backgroundColor: colorScheme.scrim.withValues(
                          alpha: 0.54,
                        ),
                        valueColor: AlwaysStoppedAnimation(
                          colorScheme.tertiary,
                        ),
                        minHeight: 3.h,
                      ),
                    ),
                  if (content.showPremiumLock)
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: colorScheme.scrim.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.tertiary,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 14.sp,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Flexible(
            child: Text(
              content.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                height: 1.2,
              ),
            ),
          ),
          if (content.cardSubtitle != null &&
              content.cardSubtitle!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              content.cardSubtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
