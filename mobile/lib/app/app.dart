import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/di/di.dart';
import '../core/services/quick_action_service.dart';
import '../core/services/token_storage_service.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import 'flavor/app_flavor.dart';
import 'routes/app_router.dart';
import 'theme/app_themes.dart';
import 'theme/theme_notifier.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    getIt<TokenStorageService>().setOnTokensCleared(() {
      ref.read(authNotifierProvider.notifier).clearSession();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      QuickActionService.register(router: ref.read(appRouterProvider));
    });
  }

  @override
  void dispose() {
    getIt<TokenStorageService>().setOnTokensCleared(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppFlavorConfig.appName,
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppThemes.buildLightTheme(),
          darkTheme: AppThemes.buildDarkTheme(),
          routerConfig: router,
          builder: (context, child) {
            final app = child ?? const SizedBox.shrink();
            if (AppFlavorConfig.isDev) {
              // return Banner(
              //   message: 'Test Build',
              //   location: BannerLocation.bottomEnd,
              //   color: Colors.red,
              //   child: app,
              // );
            }
            return app;
          },
        );
      },
    );
  }
}
