import 'package:flutter/material.dart';
import 'package:flutter_easy_messages/flutter_easy_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniott/app/routes/router_configuration.dart';
import 'package:miniott/core/utils/responsive_query.dart';
import 'package:miniott/features/auth/domain/entities/otp_purpose.dart';
import 'package:miniott/features/auth/presentation/providers/auth_providers.dart';
import 'package:miniott/features/auth/presentation/widgets/auth_textbutton.dart';
import 'package:miniott/features/auth/presentation/widgets/text_form.dart';

class ForgotPasswordForm extends ConsumerStatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  ConsumerState<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends ConsumerState<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authNotifierProvider.notifier)
        .forgotPassword(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      authNotifierProvider.select(
        (s) => (s.actionType, s.isLoading, s.successMessage, s.errorMessage),
      ),
      (previous, current) {
        if (previous == null) return;
        if (current.$1 != AuthActionType.forgotPassword) return;
        if (previous.$2 &&
            !current.$2 &&
            current.$3 != null &&
            current.$4 == null) {
          final email = _emailController.text.trim();
          context.pushNamed(
            AppRoutesNamed.verifyOtp,
            extra: <String, dynamic>{
              'email': email,
              'purpose': OtpPurpose.passwordReset,
            },
          );
        }
      },
    );

    ref.listen(authNotifierProvider.select((s) => s.forgotPasswordError), (
      previous,
      current,
    ) {
      if (current != null && previous != current) {
        showAppToast(current, context: context, messageType: MessageType.error);
      }
    });

    final isLoading = ref.watch(
      authNotifierProvider.select((s) => s.forgotPasswordLoading),
    );
    final screen = ScreenHelper(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextFormField(
            controller: _emailController,
            labelText: 'Email Address',
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
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
                      'Send Verification Code',
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
                'Remember your password? ',
                style: TextStyle(
                  fontSize: screen.isMobile ? 13 : 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              AuthTextButton(
                label: 'Login',
                onPressed: () {
                  context.go(AppRoutes.login);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
