import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/content_entity.dart';
import 'content_grid_card.dart';

class ContentGrid extends StatelessWidget {
  final List<ContentEntity> items;
  final int crossAxisCount;
  final double childAspectRatio;
  final bool showFreeTag;

  const ContentGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.6,
    this.showFreeTag = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            'No content available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 14.h,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ContentGridCard(
          content: items[index],
          showFreeTag: showFreeTag,
          onTap: () {},
        );
      },
    );
  }
}
