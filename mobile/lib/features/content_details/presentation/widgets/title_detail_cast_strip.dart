import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/title_detail.dart';

class TitleDetailCastStrip extends StatelessWidget {
  const TitleDetailCastStrip({super.key, required this.cast});

  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast & Crew',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            separatorBuilder: (context, index) => SizedBox(width: 16.w),
            itemBuilder: (context, i) {
              final m = cast[i];
              return SizedBox(
                width: 72.w,
                child: Column(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: m.avatarUrl,
                        width: 64.r,
                        height: 64.r,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => ColoredBox(
                          color: colorScheme.surfaceContainerHighest,
                          child: SizedBox(width: 64.r, height: 64.r),
                        ),
                        errorWidget: (context, url, error) => ColoredBox(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.person,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            size: 28.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      m.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
