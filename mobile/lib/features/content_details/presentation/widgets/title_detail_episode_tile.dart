import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../domain/entities/title_detail.dart';

class TitleDetailEpisodeTile extends StatelessWidget {
  const TitleDetailEpisodeTile({super.key, required this.episode, this.onPlayTap});

  final TitleEpisode episode;
  final VoidCallback? onPlayTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final row = Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 132.w,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: episode.thumbnailUrl,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => ColoredBox(
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      errorWidget: (context, url, error) => ColoredBox(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.movie_outlined,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    if (episode.isFree)
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: colorScheme.onPrimary,
                            size: 28.sp,
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: colorScheme.scrim.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(10.r),
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
                                    '${episode.coinCost ?? 50}',
                                    style: TextStyle(
                                      color: colorScheme.tertiary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.codeLabel,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  episode.duration,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                if (episode.isFree)
                  Text(
                    'Free to Watch',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  )
                else
                  Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 14.sp,
                        color: colorScheme.tertiary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Premium Required',
                        style: TextStyle(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (onPlayTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPlayTap,
        borderRadius: BorderRadius.circular(12.r),
        child: row,
      ),
    );
  }
}
