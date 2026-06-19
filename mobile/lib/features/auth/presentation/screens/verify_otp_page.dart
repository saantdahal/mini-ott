import 'package:flutter/material.dart';
import 'package:miniott/core/utils/responsive_query.dart';
import 'package:miniott/features/auth/domain/entities/otp_purpose.dart';
import 'package:miniott/features/auth/presentation/widgets/logo.dart';
import 'package:miniott/features/auth/presentation/widgets/verify_otp_form.dart';

class VerifyOtpPage extends StatelessWidget {
  const VerifyOtpPage({
    super.key,
    required this.email,
    required this.purpose,
  });

  final String email;
  final OtpPurpose purpose;

  @override
  Widget build(BuildContext context) {
    final screen = ScreenHelper(context);
    final isEmailVerify = purpose == OtpPurpose.emailVerification;

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
                      isEmailVerify ? 'Verify Email' : 'Reset Password',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: screen.isMobile ? 28 : 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    SizedBox(height: screen.spacing / 2),
                    Text(
                      isEmailVerify
                          ? 'Enter the verification code'
                          : 'Enter the code we sent to your email',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: screen.isMobile ? 14 : 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: screen.spacing * 3),
                    VerifyOtpForm(email: email, purpose: purpose),
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
