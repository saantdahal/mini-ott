import 'package:flutter/material.dart';
import 'package:flutter_easy_messages/flutter_easy_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniott/app/routes/router_configuration.dart';
import 'package:miniott/core/network/dio_error_mapper.dart';
import 'package:miniott/core/utils/responsive_query.dart';
import 'package:miniott/features/auth/presentation/widgets/auth_textbutton.dart';
import 'package:miniott/features/auth/presentation/widgets/text_form.dart';
import 'package:miniott/features/profile/di/profile_di.dart';

class ChangePasswordForm extends ConsumerStatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  ConsumerState<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends ConsumerState<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      showAppToast(
        'Passwords do not match',
        context: context,
        messageType: MessageType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(changePasswordUseCaseProvider)
          .call(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      final errorMessage = mapErrorToUserMessage(e);
      showAppToast(
        errorMessage,
        context: context,
        messageType: MessageType.error,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);

    if (_showSuccess) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Icon(
                Icons.check_circle_outline,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: screen.spacing * 2),
          Text(
            'Password Updated',
            style: TextStyle(
              fontSize: screen.isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: screen.spacing),
          Text(
            'Your password has been successfully changed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screen.isMobile ? 14 : 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          SizedBox(height: screen.spacing * 3),
          SizedBox(
            width: double.infinity,
            height: screen.spacing * 2.6,
            child: ElevatedButton(
              onPressed: () {
                context.go(AppRoutes.dashboard);
              },
              child: Text(
                'Back to Dashboard',
                style: TextStyle(
                  fontSize: screen.isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextFormField(
            controller: _currentPasswordController,
            labelText: 'Current Password',
            hintText: 'Enter your current password',
            prefixIcon: Icons.lock_outlined,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Current password is required';
              }

              return null;
            },
          ),
          SizedBox(height: screen.spacing + 10),
          CustomTextFormField(
            controller: _newPasswordController,
            labelText: 'New Password',
            hintText: 'Enter your new password',
            prefixIcon: Icons.lock_outlined,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'New password is required';
              }

              if (value.length < 8) {
                return 'At least 8 characters required';
              }

              if (value == _currentPasswordController.text) {
                return 'New password must be different from current password';
              }

              return null;
            },
          ),
          SizedBox(height: screen.spacing + 10),
          CustomTextFormField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            hintText: 'Confirm your new password',
            prefixIcon: Icons.lock_outlined,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }

              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }

              return null;
            },
          ),
          SizedBox(height: screen.spacing * 3),
          SizedBox(
            width: double.infinity,
            height: screen.spacing * 2.6,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onSubmit,
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Update Password',
                      style: TextStyle(
                        fontSize: screen.isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
          SizedBox(height: screen.spacing * 2.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Want to go back? ',
                style: TextStyle(
                  fontSize: screen.isMobile ? 13 : 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              AuthTextButton(
                label: 'Return',
                onPressed: () {
                  context.go(AppRoutes.dashboard);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
