import 'package:flutter/material.dart';
import 'package:flutter_easy_messages/flutter_easy_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniott/app/routes/router_configuration.dart';
import 'package:miniott/core/utils/responsive_query.dart';
import 'package:miniott/features/auth/presentation/providers/auth_providers.dart';
import 'package:miniott/features/auth/presentation/widgets/text_form.dart';

class SetNewPasswordForm extends ConsumerStatefulWidget {
  const SetNewPasswordForm({super.key, required this.email, required this.otp});

  final String email;
  final String otp;

  @override
  ConsumerState<SetNewPasswordForm> createState() => _SetNewPasswordFormState();
}

class _SetNewPasswordFormState extends ConsumerState<SetNewPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }
    return null;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showAppToast(
        'Passwords do not match',
        context: context,
        messageType: MessageType.error,
      );
      return;
    }

    await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(
          email: widget.email,
          otp: widget.otp,
          newPassword: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      authNotifierProvider.select(
        (s) => (s.actionType, s.isLoading, s.successMessage, s.errorMessage),
      ),
      (previous, current) {
        if (previous == null) return;
        if (current.$1 != AuthActionType.resetPassword) return;
        if (previous.$2 &&
            !current.$2 &&
            current.$3 != null &&
            current.$4 == null) {
          _passwordController.clear();
          _confirmPasswordController.clear();
          _formKey.currentState?.reset();
          showAppToast(
            current.$3 ?? 'Password updated',
            context: context,
            messageType: MessageType.success,
          );
          context.go(AppRoutes.login);
        }
      },
    );

    final isLoading = ref.watch(
      authNotifierProvider.select((s) => s.resetPasswordLoading),
    );

    ref.listen(authNotifierProvider.select((s) => s.resetPasswordError), (
      previous,
      current,
    ) {
      if (current != null && previous != current) {
        showAppToast(current, context: context, messageType: MessageType.error);
      }
    });

    final screen = ScreenHelper(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter a new password for your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screen.isMobile ? 14 : 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          SizedBox(height: screen.spacing * 2.5),
          CustomTextFormField(
            controller: _passwordController,
            labelText: 'New Password',
            hintText: 'Enter your new password',
            prefixIcon: Icons.lock_outlined,
            obscureText: true,
            validator: _validatePassword,
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
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: screen.spacing * 2.5),
          SizedBox(
            width: double.infinity,
            height: screen.spacing * 2.6,
            child: ElevatedButton(
              onPressed: isLoading ? null : _onSubmit,
              child: isLoading
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
                      'Reset Password',
                      style: TextStyle(
                        fontSize: screen.isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
          SizedBox(height: screen.spacing * 2.5),
        ],
      ),
    );
  }
}
