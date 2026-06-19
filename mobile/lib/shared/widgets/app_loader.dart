import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: const CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppColors.primary,
      ),
    );
  }
}
