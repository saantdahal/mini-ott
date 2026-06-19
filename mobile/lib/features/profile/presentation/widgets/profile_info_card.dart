import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../../domain/entities/user_profile.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key, required this.profile, this.onDark = false});

  final UserProfile profile;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final colorScheme = Theme.of(context).colorScheme;

    final infoItems = [
      ('Email', profile.email),
      if (profile.phone != null) ('Phone', profile.phone!),
      if (profile.gender != null) ('Gender', profile.gender!),
      if (profile.dateOfBirth != null) ('Date of Birth', profile.dateOfBirth!),
      if (profile.country != null) ('Country', profile.country!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: screen.isMobile ? 16.sp : 18.sp,
            fontWeight: FontWeight.bold,
            color: onDark ? colorScheme.onSurface : null,
          ),
        ),
        SizedBox(height: screen.spacing),
        Container(
          decoration: BoxDecoration(
            color: onDark ? colorScheme.surfaceContainer : colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: onDark
                  ? colorScheme.outlineVariant
                  : colorScheme.outlineVariant,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: infoItems.length,
            separatorBuilder: (context, index) => Divider(
              height: 0,
              color: onDark
                  ? colorScheme.outlineVariant
                  : colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final (label, value) = infoItems[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: screen.isMobile ? 12.h : 14.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: screen.isMobile ? 14.sp : 15.sp,
                        color: onDark
                            ? colorScheme.onSurfaceVariant
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: screen.isMobile ? 14.sp : 15.sp,
                          fontWeight: FontWeight.w500,
                          color: onDark ? colorScheme.onSurface : null,
                        ),
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
