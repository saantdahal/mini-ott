import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:miniott/gen/assets.gen.dart';

import '../../../../core/utils/responsive_query.dart';

/// Payment method selector
class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    return Row(
      children: [
        Expanded(
          child: _PaymentMethodButton(
            isSelected: selectedMethod == 'esewa',
            onTap: () => onMethodSelected('esewa'),
            label: 'eSewa',
            icon: Assets.images.esewa,
            screen: screen,
          ),
        ),
        SizedBox(width: screen.isMobile ? 12.w : 16.w),
        Expanded(
          child: _PaymentMethodButton(
            isSelected: selectedMethod == 'khalti',
            onTap: () => onMethodSelected('khalti'),
            label: 'Khalti',
            icon: Assets.images.khalti,
            screen: screen,
          ),
        ),
      ],
    );
  }
}

/// Payment method button widget
class _PaymentMethodButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  final AssetGenImage icon;
  final ScreenHelper screen;

  const _PaymentMethodButton({
    required this.isSelected,
    required this.onTap,
    required this.label,
    required this.icon,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: screen.isMobile ? 14.w : 16.w,
          vertical: screen.isMobile ? 14.h : 16.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screen.isMobile ? 14.r : 16.r),
          border: Border.all(
            color: isSelected ? primary : colorScheme.outlineVariant,
            width: isSelected ? 2.5 : 1.5,
          ),
          color: isSelected
              ? primary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainer,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            icon.image(
              width: screen.isMobile ? 28.w : 32.w,
              height: screen.isMobile ? 28.h : 32.h,
            ),
            SizedBox(height: screen.isMobile ? 10.h : 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? primary : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: screen.isMobile ? 13.sp : 14.sp,
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: screen.isMobile ? 4.w : 6.w),
                  FaIcon(
                    FontAwesomeIcons.circleCheck,
                    size: screen.isMobile ? 14.sp : 16.sp,
                    color: primary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
