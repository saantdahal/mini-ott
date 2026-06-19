import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../../domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    this.onEditTap,
    this.pulseChrome = false,
    this.showPremiumBadge = false,
  });

  final UserProfile profile;
  final VoidCallback? onEditTap;
  final bool pulseChrome;
  final bool showPremiumBadge;

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(height: screen.spacing),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            _avatarShell(context, screen),
            if (onEditTap != null)
              GestureDetector(
                onTap: onEditTap,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pulseChrome ? colorScheme.primary : colorScheme.primary,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2.w,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 18.sp,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: screen.spacing),
        Text(
          profile.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: screen.isMobile ? 24.sp : 28.sp,
            fontWeight: FontWeight.w800,
            color: pulseChrome ? colorScheme.onSurface : null,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          profile.email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: screen.isMobile ? 13.sp : 15.sp,
            color: pulseChrome
                ? colorScheme.onSurfaceVariant
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        if (showPremiumBadge)
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: colorScheme.tertiary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16.sp,
                    color: colorScheme.onTertiary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'PREMIUM MEMBER',
                    style: TextStyle(
                      color: colorScheme.onTertiary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (profile.isEmailVerified)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 14.sp, color: colorScheme.primary),
                  SizedBox(width: 4.w),
                  Text(
                    'Email Verified',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatarShell(BuildContext context, ScreenHelper screen) {
    final size = screen.isMobile ? 120.w : 140.w;
    final avatar = ClipOval(
      child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
          ? Image.network(
              profile.avatarUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildInitials(context, size);
              },
            )
          : _buildInitials(context, size),
    );

    if (!pulseChrome) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primaryContainer,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3.w,
          ),
        ),
        child: avatar,
      );
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.tertiary,
            Theme.of(context).colorScheme.primary,
          ],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: ClipOval(child: avatar),
        ),
      ),
    );
  }

  Widget _buildInitials(BuildContext context, double size) {
    final initials = profile.name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    return Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 40.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
