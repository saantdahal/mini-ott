import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_messages/flutter_easy_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:miniott/app/routes/router_configuration.dart';
import 'package:miniott/core/utils/responsive_query.dart';
import 'package:miniott/features/auth/domain/entities/otp_purpose.dart';
import 'package:miniott/features/auth/presentation/providers/auth_providers.dart';
import 'package:miniott/features/auth/presentation/widgets/auth_textbutton.dart';
import 'package:miniott/features/auth/presentation/widgets/social_buttons.dart';
import 'package:miniott/features/auth/presentation/widgets/text_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      _emailController.text = 'sakarchaulagain1@gmail.com';
      _passwordController.text = 'Sakkaar.com@123';
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      debugPrint('Google sign-in started');
      final serverClientId = dotenv.env['DEV_GOOGLE_CLIENT_ID'] ?? '';
      if (serverClientId.isEmpty) {
        debugPrint('Warning: DEV_GOOGLE_CLIENT_ID is empty in .env');
      }
      final googleSignInWithId = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: serverClientId,
      );
      final account = await googleSignInWithId.signIn();
      debugPrint('googleSignIn.signIn() returned: $account');

      if (account == null) {
        debugPrint('Google sign-in cancelled by user');
        if (mounted) {
          showAppToast(
            'Sign in cancelled',
            context: context,
            messageType: MessageType.info,
          );
        }
        return;
      }

      debugPrint('Fetching Google auth tokens');
      final googleAuth = await account.authentication;
      
      debugPrint('Signing into Firebase with Google credential');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseToken = await userCredential.user!.getIdToken();

      if (firebaseToken == null) {
        debugPrint('firebaseToken is null after Firebase authentication');
        if (mounted) {
          showAppToast(
            'Failed to get Firebase token. Try again.',
            context: context,
            messageType: MessageType.error,
          );
        }
        return;
      }

      debugPrint('Sending Firebase token to backend (length=${firebaseToken.length})');
      if (mounted) {
        await ref
            .read(authNotifierProvider.notifier)
            .googleLogin(idToken: firebaseToken);
      }
    } on PlatformException catch (e) {
      debugPrint(
        'Google Sign-In PlatformException: code=${e.code} message=${e.message} details=${e.details}',
      );
      if (mounted) {
        showAppToast(
          'Google Sign-In error: ${e.code} ${e.message ?? ''}',
          context: context,
          messageType: MessageType.error,
        );
      }
    } catch (e, st) {
      debugPrint('Google Sign-In error: $e');
      debugPrintStack(label: 'google_signin_stack', stackTrace: st);
      if (mounted) {
        showAppToast(
          'Google Sign-In error: ${e.toString()}',
          context: context,
          messageType: MessageType.error,
        );
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = appleCredential.identityToken;
      if (identityToken == null) {
        if (mounted) {
          showAppToast(
            'Failed to get Apple token',
            context: context,
            messageType: MessageType.error,
          );
        }
        return;
      }

      debugPrint('Signing into Firebase with Apple credential');
      final credential = OAuthProvider('apple.com').credential(
        idToken: identityToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseToken = await userCredential.user!.getIdToken();

      if (firebaseToken == null) {
        if (mounted) {
          showAppToast(
            'Failed to get Firebase token',
            context: context,
            messageType: MessageType.error,
          );
        }
        return;
      }

      if (mounted) {
        await ref
            .read(authNotifierProvider.notifier)
            .appleLogin(
              identityToken: firebaseToken,
              email: appleCredential.email,
              fullName:
                  appleCredential.givenName != null || appleCredential.familyName != null
                  ? '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                        .trim()
                  : null,
            );
      }
    } catch (e) {
      if (mounted) {
        showAppToast(
          e.toString(),
          context: context,
          messageType: MessageType.error,
        );
      }
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authNotifierProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      authNotifierProvider.select(
        (s) => (s.loginEmailForVerification, s.user?.id, s.actionType),
      ),
      (previous, current) {
        if (previous == null) return;
        if (previous.$1 != current.$1 && current.$1 != null) {
          final email = current.$1!;
          ref.read(authNotifierProvider.notifier).clearVerificationHints();
          context.pushNamed(
            AppRoutesNamed.verifyOtp,
            extra: <String, dynamic>{
              'email': email,
              'purpose': OtpPurpose.emailVerification,
            },
          );
        } else if (previous.$2 == null &&
            current.$2 != null &&
            current.$3 == AuthActionType.login) {
          _emailController.clear();
          _passwordController.clear();
          _formKey.currentState?.reset();
          if (context.mounted) {
            context.go(AppRoutes.dashboard);
          }
        }
      },
    );

    ref.listen(authNotifierProvider.select((s) => s.loginError), (
      previous,
      current,
    ) {
      if (current != null && previous != current) {
        showAppToast(current, context: context, messageType: MessageType.error);
      }
    });

    final isLoading = ref.watch(
      authNotifierProvider.select((s) => s.loginLoading),
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
          Align(
            alignment: Alignment.centerRight,
            child: AuthTextButton(
              label: 'Forgot Password?',
              onPressed: () {
                context.go(AppRoutes.forgotPassword);
              },
            ),
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
                      'Sign In',
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
                onPressed: _handleGoogleSignIn,
                tooltip: 'Google',
              ),
              SizedBox(width: screen.spacing * 2),
              SocialIconButton(
                iconData: FontAwesomeIcons.apple,
                onPressed: _handleAppleSignIn,
                tooltip: 'Apple',
              ),
            ],
          ),
          SizedBox(height: screen.spacing * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                  fontSize: screen.isMobile ? 13 : 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              AuthTextButton(
                label: 'Sign Up',
                onPressed: () {
                  context.go(AppRoutes.signup);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
