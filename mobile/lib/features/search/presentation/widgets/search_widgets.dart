import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';

class SearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onOpenContentTypeFilter;
  final String hintText;
  final bool darkStyle;
  final bool contentTypeFilterActive;

  const SearchBar({
    super.key,
    required this.onChanged,
    required this.onClear,
    required this.onOpenContentTypeFilter,
    this.hintText = 'Search movies, series...',
    this.darkStyle = true,
    this.contentTypeFilterActive = false,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final colorScheme = Theme.of(context).colorScheme;
    final fill = colorScheme.surfaceContainer;
    final hintC = colorScheme.onSurfaceVariant;
    final iconC = colorScheme.onSurfaceVariant;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screen.paddingAllEdgeInsets,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: widget.darkStyle
            ? fill
            : Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: screen.isMobile ? 14.sp : 15.sp,
        ),
        cursorColor: colorScheme.primary,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 14.h),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: hintC,
            fontSize: screen.isMobile ? 14.sp : 15.sp,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: iconC, size: 22.sp),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: widget.onOpenContentTypeFilter,
                tooltip: 'Content type',
                icon: Icon(
                  Icons.tune_rounded,
                  color: widget.contentTypeFilterActive
                      ? colorScheme.primary
                      : iconC,
                  size: 22.sp,
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onClear();
                    setState(() {});
                  },
                  icon: Icon(Icons.close_rounded, color: iconC, size: 22.sp),
                ),
            ],
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

enum TrendingChipVariant { purple, gold, muted }

class TrendingSearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final TrendingChipVariant variant;

  const TrendingSearchChip({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = TrendingChipVariant.muted,
  });

  @override
  Widget build(BuildContext context) {
    late Color border;
    late Color fg;
    switch (variant) {
      case TrendingChipVariant.purple:
        border = Theme.of(context).colorScheme.primary;
        fg = Theme.of(context).colorScheme.primary;
      case TrendingChipVariant.gold:
        border = Theme.of(context).colorScheme.tertiary;
        fg = Theme.of(context).colorScheme.tertiary;
      case TrendingChipVariant.muted:
        border = Theme.of(context).colorScheme.outline;
        fg = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            border: Border.all(color: border, width: 1.5),
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#',
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenreFilterChip extends StatelessWidget {
  final String genre;
  final bool isSelected;
  final VoidCallback onTap;

  const GenreFilterChip({
    super.key,
    required this.genre,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Text(
            genre,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}
