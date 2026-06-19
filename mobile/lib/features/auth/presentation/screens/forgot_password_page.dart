import 'package:flutter/material.dart';
import 'package:miniott/core/utils/responsive_query.dart';
import 'package:miniott/features/auth/presentation/widgets/forgot_password_form.dart';
import 'package:miniott/features/auth/presentation/widgets/logo.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screen.maxWidth),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screen.paddingAllEdgeInsets,
                  vertical: screen.spacing,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screen.spacing * 2),
                    const AppLogo(),
                    SizedBox(height: screen.spacing * 2),
                    Text(
                      'Reset Password',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: screen.isMobile ? 28 : 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    SizedBox(height: screen.spacing / 2),
                    Text(
                      'Recover your account access',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: screen.isMobile ? 14 : 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: screen.spacing * 3),
                    const ForgotPasswordForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
