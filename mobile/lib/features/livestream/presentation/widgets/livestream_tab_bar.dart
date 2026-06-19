import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LivestreamTabBar extends StatelessWidget {
  const LivestreamTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.counts,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<int?>? counts;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = selectedIndex == index;
          final count = counts != null && index < counts!.length
              ? counts![index]
              : null;
          return Expanded(
            child: InkWell(
              onTap: () => onTabChanged(index),
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.only(top: 14.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tabs[index],
                          style: TextStyle(
                            color: selected
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                            fontSize: 14.sp,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (count != null && count > 0) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              count > 999 ? '999+' : '$count',
                              style: TextStyle(
                                color: selected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 10.h),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: 3.h,
                      width: selected ? 28.w : 0,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
