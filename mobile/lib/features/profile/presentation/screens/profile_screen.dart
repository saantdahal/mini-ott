import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/router_configuration.dart';
import '../../../../app/flavor/app_flavor.dart';
import '../../../../app/theme/theme_notifier.dart';
import '../../../../core/utils/responsive_query.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_edit_form.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/theme_selector_bottom_sheet.dart';
import '../../../coins/presentation/providers/coin_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsExpanded = false;
  bool _newEpisodes = true;
  bool _liveEvents = false;
  bool _coinOffers = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(profileNotifierProvider.notifier).loadProfile(),
    );
    Future.microtask(
      () => ref.read(coinNotifierProvider.notifier).fetchWallet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final colorScheme = Theme.of(context).colorScheme;
    final profileState = ref.watch(profileNotifierProvider);
    final profileNotifier = ref.read(profileNotifierProvider.notifier);
    final walletBalance = ref.watch(
      coinNotifierProvider.select((state) => state.wallet?.balanceCoins ?? 0),
    );

    ref.listen(profileNotifierProvider, (previous, next) {
      final msg = next.successMessage;
      if (msg != null &&
          msg.isNotEmpty &&
          next.actionType != ProfileActionType.changePassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    ref.listen(profileNotifierProvider, (previous, next) {
      final err = next.errorMessage;
      if (err != null &&
          err.isNotEmpty &&
          next.actionType != ProfileActionType.changePassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    if (profileState.loadProfileLoading && profileState.profile == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: AppLoader()),
      );
    }

    if (profileState.profile == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          title: Text(
            'Profile',
            style: TextStyle(fontSize: screen.isMobile ? 18.sp : 20.sp),
          ),
        ),
        body: Center(
          child: AppErrorState(
            message: profileState.loadProfileError ?? 'Failed to load profile',
            onRetry: () => profileNotifier.loadProfile(),
          ),
        ),
      );
    }

    final profile = profileState.profile!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: () => profileNotifier.loadProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 80,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screen.paddingAllEdgeInsets,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.paddingOf(context).top + 8.h),
                  _topBar(context, screen, walletBalance),
                  SizedBox(height: 8.h),
                  ProfileHeader(
                    profile: profile,
                    pulseChrome: true,
                    showPremiumBadge: true,
                    onEditTap: () => _showEditProfileSheet(
                      context,
                      profile,
                      profileNotifier,
                      screen,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _statsRow(profile),
                  SizedBox(height: 18.h),
                  _activityGrid(),
                  SizedBox(height: 22.h),
                  _sectionHeader('PREFERENCES'),
                  SizedBox(height: 8.h),
                  _sectionGroup([
                    _notificationsExpandableContent(),
                    _divider(),
                    _themeRow(),
                  ]),
                  SizedBox(height: 18.h),
                  _sectionHeader('ACCOUNT'),
                  SizedBox(height: 8.h),
                  _sectionGroup([
                    _navRow(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      onTap: () =>
                          context.push(AppRoutes.profileChangePassword),
                    ),
                    _divider(),
                    _navRow(
                      icon: Icons.link_rounded,
                      label: 'Linked Accounts',
                      onTap: () {},
                    ),
                  ]),
                  SizedBox(height: 18.h),
                  _sectionHeader('SUPPORT'),
                  SizedBox(height: 8.h),
                  _sectionGroup([
                    _navRow(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      onTap: () {},
                    ),
                    _divider(),
                    _navRow(
                      icon: Icons.logout_rounded,
                      label: 'Log Out',
                      onTap: () => _showLogoutDialog(context),
                      destructive: true,
                    ),
                  ]),
                  SizedBox(height: 20.h),
                  _dangerZoneLink(profileNotifier),
                  SizedBox(height: 24.h),
                  ProfileInfoCard(profile: profile, onDark: true),
                  SizedBox(height: screen.spacing * 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, ScreenHelper screen, int walletBalance) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          AppFlavorConfig.appName,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: screen.isMobile ? 22.sp : 24.sp,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        Material(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            onTap: () => context.push(AppRoutes.coins),
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.coins,
                    size: 14.sp,
                    color: colorScheme.tertiary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '$walletBalance',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: screen.isMobile ? 13.sp : 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statsRow(UserProfile profile) {
    final memberLabel = _formatJoinDate(profile.createdAt);
    final verified = profile.isEmailVerified;
    return Row(
      children: [
        _statChip(
          icon: Icons.calendar_today_rounded,
          label: 'Member',
          value: memberLabel,
        ),
        SizedBox(width: 8.w),
        _statChip(
          icon: Icons.workspace_premium_rounded,
          label: 'Plan',
          value: 'Free',
        ),
        SizedBox(width: 8.w),
        _statChip(
          icon: verified ? Icons.verified_rounded : Icons.pending_rounded,
          label: 'Email',
          value: verified ? 'Verified' : 'Pending',
        ),
      ],
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.onSurfaceVariant, size: 14.sp),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityGrid() {
    return Row(
      children: [
        Expanded(
          child: _activityCard(
            icon: Icons.history_rounded,
            label: 'History',
            onTap: () => context.push(AppRoutes.watchHistory),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _activityCard(
            icon: Icons.receipt_long_rounded,
            label: 'Payments',
            onTap: () => context.push(AppRoutes.paymentHistory),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _activityCard(
            icon: Icons.bookmark_outline_rounded,
            label: 'Saved',
            onTap: () => context.push(AppRoutes.watchLater),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _activityCard(
            icon: Icons.confirmation_number_outlined,
            label: 'Vouchers',
            onTap: () => context.push(AppRoutes.profileVouchers),
          ),
        ),
      ],
    );
  }

  Widget _activityCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 14.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: colorScheme.onSurface, size: 20.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _sectionGroup(List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(children: children),
      ),
    );
  }

  Widget _divider() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Divider(height: 1.h, color: colorScheme.outlineVariant),
    );
  }

  Widget _navRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool destructive = false,
    Widget? trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = destructive ? colorScheme.error : colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: destructive ? fg : colorScheme.onSurfaceVariant,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: destructive
                        ? fg.withValues(alpha: 0.55)
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    size: 20.sp,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationsExpandableContent() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _navRow(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          onTap: () =>
              setState(() => _notificationsExpanded = !_notificationsExpanded),
          trailing: AnimatedRotation(
            turns: _notificationsExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.expand_more_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: 20.sp,
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
            child: Column(
              children: [
                Divider(height: 1.h, color: colorScheme.outlineVariant),
                _notificationToggleRow(
                  icon: Icons.auto_awesome_rounded,
                  label: 'New Episodes',
                  value: _newEpisodes,
                  onChanged: (v) => setState(() => _newEpisodes = v),
                ),
                _notificationToggleRow(
                  icon: Icons.live_tv_rounded,
                  label: 'Live Events',
                  value: _liveEvents,
                  onChanged: (v) => setState(() => _liveEvents = v),
                ),
                _notificationToggleRow(
                  icon: Icons.monetization_on_rounded,
                  label: 'Coin Offers',
                  value: _coinOffers,
                  onChanged: (v) => setState(() => _coinOffers = v),
                  iconColor: colorScheme.tertiary,
                ),
              ],
            ),
          ),
          crossFadeState: _notificationsExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    );
  }

  Widget _notificationToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: iconColor ?? colorScheme.onSurfaceVariant,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.78,
            child: Switch(
              value: value,
              onChanged: onChanged,
              thumbColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              trackColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
              ),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeRow() {
    final colorScheme = Theme.of(context).colorScheme;
    final currentTheme = ref.watch(themeNotifierProvider);
    return _navRow(
      icon: Icons.palette_rounded,
      label: 'Theme',
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          builder: (sheetContext) => ThemeSelectorBottomSheet(
            currentTheme: currentTheme,
            onThemeSelected: (selected) {
              ref.read(themeNotifierProvider.notifier).setTheme(selected);
            },
          ),
        );
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentTheme.label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _dangerZoneLink(ProfileNotifier profileNotifier) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: TextButton.icon(
        onPressed: () => _showDeleteAccountDialog(context, profileNotifier),
        icon: Icon(
          Icons.delete_outline_rounded,
          size: 16.sp,
          color: colorScheme.error.withValues(alpha: 0.85),
        ),
        label: Text(
          'Delete account',
          style: TextStyle(
            color: colorScheme.error.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime? d) {
    if (d == null) return 'New';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final yy = d.year.toString().substring(2);
    return "${months[d.month - 1]} '$yy";
  }

  void _showEditProfileSheet(
    BuildContext context,
    dynamic profile,
    dynamic profileNotifier,
    ScreenHelper screen,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(profileNotifierProvider);
              return ProfileEditForm(
                fullName: profile.name,
                phone: profile.phone,
                gender: profile.gender,
                dateOfBirth: profile.dateOfBirth,
                country: profile.country,
                isLoading: state.updateProfileLoading,
                onSave: (data) {
                  profileNotifier.updateProfile(
                    name: data['name'],
                    phone: data['phone'],
                    gender: data['gender'],
                    dateOfBirth: data['dateOfBirth'],
                    country: data['country'],
                    avatarPath: data['avatarPath'],
                  );
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    ProfileNotifier profileNotifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final passwordController = TextEditingController();
    bool obscure = true;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              backgroundColor: colorScheme.surfaceContainer,
              title: const Text('Delete Account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'This action cannot be undone. Enter your password to confirm.',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setLocal(() => obscure = !obscure),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final pw = passwordController.text.trim();
                    if (pw.isEmpty) return;
                    Navigator.pop(dialogContext);
                    profileNotifier.deleteAccount(password: pw);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainer,
        title: const Text('Logout'),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
