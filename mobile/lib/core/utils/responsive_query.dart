import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenHelper {
  final BuildContext context;
  final double screenWidth;

  ScreenHelper(this.context) : screenWidth = MediaQuery.of(context).size.width;

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;

  double get paddingAllEdgeInsets => isMobile ? 16.w : (isTablet ? 20.0 : 24.0);
  double get titleFontSize => isMobile ? 28.sp : (isTablet ? 32 : 36);
  double get spacing => isMobile ? 16.h : (isTablet ? 18 : 20);
  double get maxWidth => isMobile ? double.infinity : (isTablet ? 500 : 600);

  int get coinPackageGridColumns {
    if (screenWidth >= 1100) return 4;
    if (screenWidth >= 760) return 3;
    return 2;
  }

  double coinPackageGridMainExtentScaled(TextScaler textScaler) {
    final base = isMobile ? 168.h : 184.h;
    final f = (textScaler.scale(14) / 14.0).clamp(1.0, 1.34);
    return base * f;
  }
}
