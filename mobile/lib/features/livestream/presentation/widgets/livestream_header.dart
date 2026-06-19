import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miniott/shared/widgets/widgets.dart';

class LivestreamHeader extends StatelessWidget {
  const LivestreamHeader({
    super.key,
    required this.heroImageUrl,
    required this.quality,
    required this.viewerCount,
    required this.onShare,
    required this.onMore,
    this.streamerName,
    this.streamerAvatar,
    this.title,
  });

  final String heroImageUrl;
  final String quality;
  final int viewerCount;
  final VoidCallback onShare;
  final VoidCallback onMore;
  final String? streamerName;
  final String? streamerAvatar;
  final String? title;

  static String formatViewerCount(int n) {
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1)}M';
    }
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: heroImageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                ColoredBox(color: colorScheme.surfaceContainerHighest),
            errorWidget: (context, url, error) => ColoredBox(
              color: colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.music_note_rounded,
                color: colorScheme.primary.withValues(alpha: 0.5),
                size: 64.sp,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.scrim.withValues(alpha: 0.55),
                  colorScheme.scrim.withValues(alpha: 0.05),
                  colorScheme.scrim.withValues(alpha: 0.55),
                  colorScheme.scrim.withValues(alpha: 0.92),
                ],
                stops: const [0.0, 0.35, 0.7, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: topPad + 6.h,
          left: 20.w,
          right: 20.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconButton(
                    onPressed: onShare,
                    icon: Icons.ios_share_rounded,
                  ),
                  SizedBox(width: 10.w),
                  CustomIconButton(
                    onPressed: onMore,
                    icon: Icons.more_vert_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 12.w,
          right: 12.w,
          bottom: 14.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (streamerName != null || title != null)
                _buildStreamerRow(colorScheme),
              if (streamerName != null || title != null) SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLiveBadge(colorScheme),
                  SizedBox(width: 8.w),
                  _buildQualityBadge(colorScheme),
                  const Spacer(),
                  _buildViewerBadge(colorScheme),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreamerRow(ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (streamerAvatar != null && streamerAvatar!.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.onSurface, width: 2),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: streamerAvatar!,
                width: 36.r,
                height: 36.r,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 36.r,
                  height: 36.r,
                  color: colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 36.r,
                  height: 36.r,
                  color: colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.person_rounded,
                    size: 18.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        if (streamerAvatar != null && streamerAvatar!.isNotEmpty)
          SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                    shadows: [
                      Shadow(
                        color: colorScheme.scrim.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              if (streamerName != null)
                Text(
                  streamerName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.85),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveBadge(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(
              color: colorScheme.onError,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onError.withValues(alpha: 0.8),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'LIVE',
            style: TextStyle(
              color: colorScheme.onError,
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityBadge(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colorScheme.scrim.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Text(
        quality,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildViewerBadge(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: colorScheme.scrim.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_rounded,
            color: colorScheme.onSurface,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            formatViewerCount(viewerCount),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
