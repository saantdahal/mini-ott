import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../app/routes/router_configuration.dart';

class AppNavigationLayout extends StatefulWidget {
  final Widget child;

  const AppNavigationLayout({super.key, required this.child});

  @override
  State<AppNavigationLayout> createState() => _AppNavigationLayoutState();
}

class _AppNavigationLayoutState extends State<AppNavigationLayout> {
  static const _items = <_OttNavItem>[
    _OttNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _OttNavItem(
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: 'Search',
    ),
    _OttNavItem(
      icon: Icons.play_circle_outline_rounded,
      activeIcon: Icons.play_circle_rounded,
      label: 'Live',
    ),
    _OttNavItem(
      icon: Icons.monetization_on_outlined,
      activeIcon: Icons.monetization_on_rounded,
      label: 'Coins',
    ),
    _OttNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  int _getCurrentIndex(String location) {
    if (location.startsWith(AppRoutes.dashboard)) return 0;
    if (location.startsWith(AppRoutes.search)) return 1;
    if (location.startsWith(AppRoutes.ott)) return 2;
    if (location.startsWith(AppRoutes.coins)) return 3;
    if (location.startsWith(AppRoutes.profile)) {
      return 4; // Profile/Admin placeholder
    }
    return 0;
  }

  void _handleNavigation(int index) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.search);
        break;
      case 2:
        context.go(AppRoutes.ott);
        break;
      case 3:
        context.go(AppRoutes.coins);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _OttBottomNav(
        currentIndex: currentIndex,
        items: _items,
        onTap: _handleNavigation,
      ),
    );
  }
}

class _OttNavItem {
  const _OttNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _OttBottomNav extends StatelessWidget {
  const _OttBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<_OttNavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        // Subtle gradient blends into the page above and gives the bar
        // a faint sense of depth without committing to a full glass blur.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.surface,
            Color.alphaBlend(cs.primary.withValues(alpha: 0.04), cs.surface),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (i) {
              return Expanded(
                child: _OttNavTab(
                  item: items[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _OttNavTab extends StatelessWidget {
  const _OttNavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _OttNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = cs.primary;
    final inactiveColor = cs.onSurfaceVariant.withValues(alpha: 0.78);

    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        splashColor: cs.primary.withValues(alpha: 0.10),
        highlightColor: cs.primary.withValues(alpha: 0.06),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 18.w : 10.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? cs.primary.withValues(alpha: 0.16)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: Tween<double>(begin: 0.85, end: 1.0).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    selected ? item.activeIcon : item.icon,
                    key: ValueKey<bool>(selected),
                    color: selected ? activeColor : inactiveColor,
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                style: TextStyle(
                  color: selected ? activeColor : inactiveColor,
                  fontSize: 10.5.sp,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.15,
                  height: 1.0,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
