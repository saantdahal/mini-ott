import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/responsive_query.dart';
import '../providers/profile_providers.dart';
import 'standard_text_field.dart';

class ProfileChangePasswordForm extends ConsumerStatefulWidget {
  const ProfileChangePasswordForm({super.key});

  @override
  ConsumerState<ProfileChangePasswordForm> createState() =>
      _ChangePasswordFormState();
}

class _ChangePasswordFormState
    extends ConsumerState<ProfileChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(profileNotifierProvider.notifier)
          .changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final isLoading = ref.watch(
      profileNotifierProvider.select((s) => s.changePasswordLoading),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StandardTextField(
            label: 'Current password',
            hint: 'Enter your current password',
            controller: _currentPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            enabled: !isLoading,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Current password is required';
              }
              return null;
            },
          ),
          SizedBox(height: screen.spacing),
          StandardTextField(
            label: 'New password',
            hint: 'At least 8 characters',
            controller: _newPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock_rounded,
            enabled: !isLoading,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'New password is required';
              }
              if ((value?.length ?? 0) < 8) {
                return 'Password must be at least 8 characters';
              }
              if (value == _currentPasswordController.text) {
                return 'Must differ from your current password';
              }
              return null;
            },
          ),
          SizedBox(height: screen.spacing),
          StandardTextField(
            label: 'Confirm new password',
            hint: 'Re-enter new password',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock_rounded,
            enabled: !isLoading,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please confirm your password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: screen.spacing * 1.75),
          SizedBox(
            height: 50.h,
            child: FilledButton(
              onPressed: isLoading ? null : _handleSubmit,
              child: isLoading
                  ? SizedBox(
                      height: 22.h,
                      width: 22.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      'Update password',
                      style: TextStyle(
                        fontSize: screen.isMobile ? 15.sp : 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
