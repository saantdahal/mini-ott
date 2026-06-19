import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// iOS-style back button widget with typical Cupertino appearance
class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.onPressed,
    this.color,
    this.size,
    required this.icon,
  });

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Icon for the button
  final IconData icon;

  /// Color of the back button (defaults to primary color)
  final Color? color;

  /// Size of the button
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedColor = color ?? colorScheme.onSurface;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surfaceContainer,
          border: Border.all(color: resolvedColor, width: 1.5),
        ),
        child: Icon(icon, color: resolvedColor, size: size ?? 18.sp),
      ),
    );
  }
}
