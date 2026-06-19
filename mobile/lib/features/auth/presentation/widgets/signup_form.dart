import 'package:flutter/material.dart';
import 'package:flutter_easy_messages/flutter_easy_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:miniott/app/routes/router_configuration.dart';
import 'package:miniott/core/utils/responsive_query.dart';
import 'package:miniott/features/auth/domain/entities/otp_purpose.dart';
import 'package:miniott/features/auth/presentation/providers/auth_providers.dart';
import 'package:miniott/features/auth/presentation/widgets/auth_textbutton.dart';
import 'package:miniott/features/auth/presentation/widgets/social_buttons.dart';
import 'package:miniott/features/auth/presentation/widgets/text_form.dart';

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
        .signup(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          country: null,
          gender: null,
          dateOfBirth: null,
          avatarPath: null,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      authNotifierProvider.select(
        (s) => (s.signupEmailForVerification, s.successMessage),
      ),
      (previous, current) {
        if (previous == null) return;
        if (previous.$1 == current.$1) return;
        if (current.$1 == null) return;
        final email = current.$1!;
        showAppToast(
          current.$2 ?? 'Check your email for the code',
          context: context,
          messageType: MessageType.success,
        );
        _fullNameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _formKey.currentState?.reset();
        context.pushNamed(
          AppRoutesNamed.verifyOtp,
          extra: <String, dynamic>{
            'email': email,
            'purpose': OtpPurpose.emailVerification,
          },
        );
        ref.read(authNotifierProvider.notifier).clearVerificationHints();
      },
    );

    final isLoading = ref.watch(
      authNotifierProvider.select((s) => s.signupLoading),
    );

    ref.listen(authNotifierProvider.select((s) => s.signupError), (
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
          CustomTextFormField(
            controller: _fullNameController,
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name is required';
              }

              if (value.length < 3) {
                return 'Name must be at least 3 characters';
              }

              return null;
            },
          ),
          SizedBox(height: screen.spacing + 10),
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
          SizedBox(height: screen.spacing + 10),
          CustomTextFormField(
            controller: _phoneController,
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }

              if (value.length < 10) {
                return 'Enter a valid phone number';
              }

              return null;
            },
          ),
          SizedBox(height: screen.spacing + 10),
          CustomTextFormField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: Icons.lock_outlined,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }

              if (value.length < 8) {
                return 'At least 8 characters required';
              }

              return null;
            },
          ),
          SizedBox(height: screen.spacing + 10),
          CustomTextFormField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            hintText: 'Confirm your password',
            prefixIcon: Icons.lock_outlined,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }

              if (value.length < 8) {
                return 'At least 8 characters required';
              }

              return null;
            },
          ),
          SizedBox(height: screen.spacing),
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
                      'Create Account',
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
            children: [
              Expanded(
                child: Divider(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screen.spacing / 2),
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          SizedBox(height: screen.spacing * 2.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialIconButton(
                iconData: FontAwesomeIcons.google,
                onPressed: () {},
                tooltip: 'Google',
              ),
              SizedBox(width: screen.spacing * 2),
              SocialIconButton(
                iconData: FontAwesomeIcons.apple,
                onPressed: () {},
                tooltip: 'Apple',
              ),
            ],
          ),
          SizedBox(height: screen.spacing * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
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
