import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive_query.dart';
import '../providers/profile_providers.dart';
import '../widgets/change_password_form.dart';

class ProfileChangePasswordScreen extends ConsumerWidget {
  const ProfileChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ScreenHelper(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    ref.listen(profileNotifierProvider, (previous, next) {
      if (next.actionType != ProfileActionType.changePassword) return;
      final msg = next.successMessage;
      if (msg != null && msg.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: cs.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(profileNotifierProvider.notifier).clearFeedback();
        if (context.mounted) context.pop();
        return;
      }
      final err = next.errorMessage;
      if (err != null &&
          err.isNotEmpty &&
          !next.changePasswordLoading &&
          (previous?.errorMessage != err)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: cs.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change password',
          style: TextStyle(fontSize: screen.isMobile ? 17.sp : 19.sp),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screen.maxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screen.paddingAllEdgeInsets,
                vertical: screen.spacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    size: screen.isMobile ? 48.sp : 56.sp,
                    color: cs.primary,
                  ),
                  SizedBox(height: screen.spacing),
                  Text(
                    'Update your password',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: screen.isMobile ? 22.sp : 26.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Use at least 8 characters. Your new password must differ from the current one.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: screen.isMobile ? 13.sp : 14.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: screen.spacing * 1.75),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screen.paddingAllEdgeInsets),
                      child: const ProfileChangePasswordForm(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
