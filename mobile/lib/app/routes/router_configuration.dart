class RouteConfiguration {
  final String name;
  final String path;
  final String title;
  final String note;

  const RouteConfiguration({
    required this.name,
    required this.path,
    required this.title,
    required this.note,
  });
}

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String setNewPassword = '/auth/set-new-password';
  static const String changePassword = '/auth/change-password';
  static const String dashboard = '/dashboard';
  static const String ott = '/ott';
  static const String voting = '/voting';
  static const String wallet = '/wallet';
  static const String coins = '/coins';
  static const String payments = '/payments';
  static const String chat = '/chat';
  static const String search = '/search';
  static const String cms = '/cms';
  static const String profile = '/profile';
  static const String profileChangePassword = '/profile/change-password';
  static const String watchHistory = '/profile/watch-history';
  static const String paymentHistory = '/profile/payment-history';
  static const String watchLater = '/profile/watch-later';
  static const String profileVouchers = '/profile/vouchers';
  static const String notifications = '/notifications';

  static String contentDetailPath(String contentId) => '/content/$contentId';
  static String categoryBrowsePath(String categoryId) => '/browse/$categoryId';

  static const String player = '/play';

  static const String initialLocation = splash;
}

class AppRoutesNamed {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgotPassword';
  static const String verifyOtp = 'verifyOtp';
  static const String setNewPassword = 'setNewPassword';
  static const String changePassword = 'changePassword';
  static const String dashboard = 'dashboard';
  static const String ott = 'ott';
  static const String voting = 'voting';
  static const String wallet = 'wallet';
  static const String coins = 'coins';
  static const String payments = 'payments';
  static const String chat = 'chat';
  static const String search = 'search';
  static const String cms = 'cms';
  static const String profile = 'profile';
  static const String profileChangePassword = 'profileChangePassword';
  static const String watchHistory = 'watchHistory';
  static const String paymentHistory = 'paymentHistory';
  static const String watchLater = 'watchLater';
  static const String profileVouchers = 'profileVouchers';
  static const String notifications = 'notifications';
  static const String networkPlayer = 'networkPlayer';
  static const String categoryBrowse = 'categoryBrowse';
}

const List<RouteConfiguration> appRouteConfigurations = <RouteConfiguration>[
  RouteConfiguration(
    name: 'splash',
    path: AppRoutes.splash,
    title: 'Splash',
    note: 'Initial app boot, token check, and route decision.',
  ),
  RouteConfiguration(
    name: 'login',
    path: AppRoutes.login,
    title: 'Login',
    note: 'Email/Password and Google login entry point.',
  ),
  RouteConfiguration(
    name: 'signup',
    path: AppRoutes.signup,
    title: 'Sign Up',
    note: 'User registration flow with validation and consent.',
  ),
  RouteConfiguration(
    name: 'forgotPassword',
    path: AppRoutes.forgotPassword,
    title: 'Forgot Password',
    note: 'Password reset flow - enter email.',
  ),
  RouteConfiguration(
    name: 'verifyOtp',
    path: AppRoutes.verifyOtp,
    title: 'Verify OTP',
    note: 'Verify 6-digit OTP sent to email.',
  ),
  RouteConfiguration(
    name: 'setNewPassword',
    path: AppRoutes.setNewPassword,
    title: 'Set New Password',
    note: 'Enter and confirm new password.',
  ),
  RouteConfiguration(
    name: 'changePassword',
    path: AppRoutes.changePassword,
    title: 'Change Password',
    note: 'Update account password for logged-in users.',
  ),
  RouteConfiguration(
    name: 'dashboard',
    path: AppRoutes.dashboard,
    title: 'User Dashboard',
    note: 'Profile, purchases, and voting history.',
  ),
  RouteConfiguration(
    name: 'ott',
    path: AppRoutes.ott,
    title: 'OTT Library',
    note: 'Video library, trending, latest shows, categories.',
  ),
  RouteConfiguration(
    name: 'voting',
    path: AppRoutes.voting,
    title: 'Voting',
    note: 'Coin-based voting journeys and event details.',
  ),
  RouteConfiguration(
    name: 'wallet',
    path: AppRoutes.wallet,
    title: 'Coin Wallet',
    note: 'Balance, top-up, and transaction history.',
  ),
  RouteConfiguration(
    name: 'coins',
    path: AppRoutes.coins,
    title: 'Buy Coins',
    note: 'Coin packages, payment gateway selection (Khalti/Esewa).',
  ),
  RouteConfiguration(
    name: 'payments',
    path: AppRoutes.payments,
    title: 'Payments',
    note: 'Esewa and Khalti integration entry points.',
  ),
  RouteConfiguration(
    name: 'chat',
    path: AppRoutes.chat,
    title: 'Chat Box',
    note: 'Basic support chat with online/offline status.',
  ),
  RouteConfiguration(
    name: 'search',
    path: AppRoutes.search,
    title: 'Search',
    note: 'Global content search across shows and pages.',
  ),
  RouteConfiguration(
    name: 'cms',
    path: AppRoutes.cms,
    title: 'CMS',
    note: 'Banners, FAQ, and informational pages management.',
  ),
  RouteConfiguration(
    name: 'profile',
    path: AppRoutes.profile,
    title: 'Profile',
    note: 'User profile management and settings.',
  ),
  RouteConfiguration(
    name: 'profileChangePassword',
    path: AppRoutes.profileChangePassword,
    title: 'Change password',
    note: 'Logged-in user password update from profile.',
  ),
  RouteConfiguration(
    name: 'watchHistory',
    path: AppRoutes.watchHistory,
    title: 'Watch history',
    note: 'Recently watched titles.',
  ),
  RouteConfiguration(
    name: 'paymentHistory',
    path: AppRoutes.paymentHistory,
    title: 'Payment history',
    note: 'Wallet top-ups and completed payments.',
  ),
  RouteConfiguration(
    name: 'watchLater',
    path: AppRoutes.watchLater,
    title: 'Saved',
    note: 'Watch later list.',
  ),
  RouteConfiguration(
    name: 'profileVouchers',
    path: AppRoutes.profileVouchers,
    title: 'My vouchers',
    note: 'Promo vouchers and redemptions.',
  ),
  RouteConfiguration(
    name: 'contentDetail',
    path: '/content/:contentId',
    title: 'Title details',
    note: 'Movie or series hero, episodes, and unlock.',
  ),
  RouteConfiguration(
    name: 'networkPlayer',
    path: AppRoutes.player,
    title: 'Player',
    note: 'Network HLS or MP4 playback from CDN keys.',
  ),
];
