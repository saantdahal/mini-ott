import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniott/core/utils/responsive_query.dart';
import 'package:miniott/gen/assets.gen.dart';

class AppLogo extends ConsumerWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ScreenHelper(context);

    return Container(
      width: screen.isMobile ? 80 : 100,
      height: screen.isMobile ? 80 : 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          Assets.images.logo.path,
          width: screen.isMobile ? 80 : 50,
          height: screen.isMobile ? 80 : 50,
        ),
      ),
    );
  }
}
