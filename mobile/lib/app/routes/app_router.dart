import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniott/features/notification/presentation/screens/notification_screen.dart';
import 'package:miniott/features/profile/presentation/screens/profile_change_password_screen.dart';
import 'package:miniott/features/profile/presentation/screens/payment_history_screen.dart';
import 'package:miniott/features/profile/presentation/screens/profile_screen.dart';
import 'package:miniott/features/profile/presentation/screens/profile_vouchers_screen.dart';
import 'package:miniott/features/profile/presentation/screens/watch_history_screen.dart';
import 'package:miniott/features/profile/presentation/screens/watch_later_screen.dart';
import '../../features/auth/domain/entities/otp_purpose.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/change_password.dart';
import '../../features/auth/presentation/screens/forgot_password_page.dart';
import '../../features/auth/presentation/screens/verify_otp_page.dart';
import '../../features/auth/presentation/screens/set_new_password_page.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/coins/presentation/screens/coin_screen.dart';
import '../../features/content_catalog/presentation/screens/category_content_screen.dart';
import '../../features/content_details/presentation/screens/title_detail_screen.dart';
import '../../features/player/domain/network_playback_args.dart';
import '../../features/player/presentation/args/video_playback_args.dart';
import '../../features/player/presentation/screens/network_video_player_screen.dart';
import '../../features/livestream/presentation/screens/livestream_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../shared/navigation_layout.dart';
import 'router_configuration.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'appRoot');
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'appShell');

  final refresh = ValueNotifier<int>(0);
  ref.listen<bool>(authNotifierProvider.select((s) => s.isAuthenticated), (
    prev,
    next,
  ) {
    if (prev != next) refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.initialLocation,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = ref.read(authNotifierProvider).isAuthenticated;
      final loc = state.matchedLocation;

      final isPublic =
          loc == AppRoutes.splash ||
          loc == AppRoutes.login ||
          loc == AppRoutes.signup ||
          loc == AppRoutes.forgotPassword ||
          loc == AppRoutes.verifyOtp ||
          loc == AppRoutes.setNewPassword;

      if (!loggedIn && !isPublic) {
        return AppRoutes.login;
      }
      if (loggedIn && (loc == AppRoutes.login || loc == AppRoutes.signup)) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        name: 'verifyOtp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          final purpose =
              extra?['purpose'] as OtpPurpose? ?? OtpPurpose.passwordReset;
          return VerifyOtpPage(email: email, purpose: purpose);
        },
      ),
      GoRoute(
        path: AppRoutes.setNewPassword,
        name: 'setNewPassword',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] as String? ?? '';
          final otp = extra?['otp'] as String? ?? '';
          return SetNewPasswordPage(email: email, otp: otp);
        },
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'changePassword',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppNavigationLayout(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.ott,
            name: 'ott',
            builder: (context, state) => const LivestreamScreen(),
          ),
          GoRoute(
            path: AppRoutes.wallet,
            name: 'wallet',
            builder: (context, state) => const CoinScreen(),
          ),
          GoRoute(
            path: AppRoutes.coins,
            name: 'coins',
            builder: (context, state) => const CoinScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.profileChangePassword,
            name: AppRoutesNamed.profileChangePassword,
            builder: (context, state) => const ProfileChangePasswordScreen(),
          ),
          GoRoute(
            path: AppRoutes.watchHistory,
            name: AppRoutesNamed.watchHistory,
            builder: (context, state) => const WatchHistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.paymentHistory,
            name: AppRoutesNamed.paymentHistory,
            builder: (context, state) => const PaymentHistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.watchLater,
            name: AppRoutesNamed.watchLater,
            builder: (context, state) => const WatchLaterScreen(),
          ),
          GoRoute(
            path: AppRoutes.profileVouchers,
            name: AppRoutesNamed.profileVouchers,
            builder: (context, state) => const ProfileVouchersScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            name: AppRoutesNamed.notifications,
            builder: (context, state) => const NotificationScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/content/:contentId',
        name: 'contentDetail',
        builder: (context, state) {
          final id = state.pathParameters['contentId'] ?? '';
          return TitleDetailScreen(contentId: id);
        },
      ),
      GoRoute(
        path: '/browse/:categoryId',
        name: AppRoutesNamed.categoryBrowse,
        builder: (context, state) {
          final id = state.pathParameters['categoryId'] ?? '';
          final extra = state.extra;
          String name = 'Browse';
          String? description;
          if (extra is Map) {
            final n = extra['name'];
            final d = extra['description'];
            if (n is String && n.isNotEmpty) name = n;
            if (d is String && d.isNotEmpty) description = d;
          }
          return CategoryContentScreen(
            categoryId: id,
            categoryName: name,
            categoryDescription: description,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.player,
        name: AppRoutesNamed.networkPlayer,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is VideoUploadPlaybackArgs) {
            return VideoUploadPlayerScreen(args: extra);
          }
          if (extra is NetworkPlaybackArgs) {
            return NetworkVideoPlayerScreen(args: extra);
          }
          return const Scaffold(
            body: Center(
              child: Text(
                'Pass VideoUploadPlaybackArgs or NetworkPlaybackArgs as extra',
              ),
            ),
          );
        },
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
