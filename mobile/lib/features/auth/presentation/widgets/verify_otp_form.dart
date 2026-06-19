import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easy_messages/flutter_easy_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniott/app/routes/router_configuration.dart';
import 'package:miniott/core/utils/responsive_query.dart';
import 'package:miniott/features/auth/domain/entities/otp_purpose.dart';
import 'package:miniott/features/auth/presentation/providers/auth_providers.dart';
import 'package:miniott/features/auth/presentation/widgets/auth_textbutton.dart';

class VerifyOtpForm extends ConsumerStatefulWidget {
  const VerifyOtpForm({super.key, required this.email, required this.purpose});

  final String email;
  final OtpPurpose purpose;

  @override
  ConsumerState<VerifyOtpForm> createState() => _VerifyOtpFormState();
}

class _VerifyOtpFormState extends ConsumerState<VerifyOtpForm> {
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _focusNodes;
  final int otpLength = 6;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getOtp() {
    return _otpControllers.map((c) => c.text).join();
  }

  bool _isOtpComplete() {
    return _otpControllers.every((c) => c.text.isNotEmpty);
  }

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

      for (var controller in _otpControllers) {
        controller.clear();
      }

      for (int i = 0; i < digits.length && i < otpLength; i++) {
        _otpControllers[i].text = digits[i];
      }

      final nextIndex = digits.length < otpLength
          ? digits.length
          : otpLength - 1;
      if (nextIndex < otpLength) {
        _focusNodes[nextIndex].requestFocus();
      } else {
        _focusNodes[otpLength - 1].unfocus();
      }
    } else if (value.isNotEmpty) {
      if (index < otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _dispatchVerify() async {
    if (!_isOtpComplete()) {
      showAppToast(
        'Please enter the complete OTP',
        context: context,
        messageType: MessageType.error,
      );
      return;
    }

    final otp = _getOtp();
    final notifier = ref.read(authNotifierProvider.notifier);

    if (widget.purpose == OtpPurpose.emailVerification) {
      await notifier.verifyEmailOtp(email: widget.email, otp: otp);
    } else {
      await notifier.verifyResetOtp(email: widget.email, otp: otp);
    }
  }

  Future<void> _dispatchResend() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    if (widget.purpose == OtpPurpose.emailVerification) {
      await notifier.resendEmailOtp(widget.email);
    } else {
      await notifier.resendPasswordResetOtp(widget.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmailFlow = widget.purpose == OtpPurpose.emailVerification;

    ref.listen(
      authNotifierProvider.select(
        (s) => (s.actionType, s.isLoading, s.successMessage, s.errorMessage),
      ),
      (previous, current) {
        if (previous == null) return;
        if (isEmailFlow) {
          if (current.$1 != AuthActionType.verifyEmailOtp) return;
          if (previous.$2 && !current.$2 && current.$3 != null) {
            showAppToast(
              current.$3 ?? 'Email verified',
              context: context,
              messageType: MessageType.success,
            );
            context.go(AppRoutes.login);
          }
          return;
        }
        if (current.$1 != AuthActionType.verifyOtp) return;
        if (previous.$2 &&
            !current.$2 &&
            current.$4 == null &&
            current.$3 == null) {
          final otp = _getOtp();
          if (otp.length == 6 && context.mounted) {
            context.pushNamed(
              AppRoutesNamed.setNewPassword,
              extra: <String, dynamic>{'email': widget.email, 'otp': otp},
            );
          }
        }
      },
    );

    final isLoading = ref.watch(
      authNotifierProvider.select(
        (s) => isEmailFlow ? s.verifyEmailOtpLoading : s.verifyResetOtpLoading,
      ),
    );

    ref.listen(
      authNotifierProvider.select(
        (s) => isEmailFlow ? s.verifyEmailOtpError : s.verifyResetOtpError,
      ),
      (previous, current) {
        if (current != null && previous != current) {
          showAppToast(
            current,
            context: context,
            messageType: MessageType.error,
          );
        }
      },
    );
    final screen = ScreenHelper(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'We sent a 6-digit verification code to:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screen.isMobile ? 14 : 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: screen.spacing / 2),
        Text(
          widget.email,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screen.isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: screen.spacing * 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(otpLength, (index) {
            final colorScheme = Theme.of(context).colorScheme;
            return SizedBox(
              width: screen.isMobile ? 44 : 52,
              height: screen.isMobile ? 56 : 64,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                cursorColor: colorScheme.primary,
                style: TextStyle(
                  fontSize: screen.isMobile ? 22 : 26,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _onOtpChanged(value, index),
              ),
            );
          }),
        ),
        SizedBox(height: screen.spacing * 2),
        SizedBox(
          width: double.infinity,
          height: screen.spacing * 2.6,
          child: ElevatedButton(
            onPressed: isLoading ? null : _dispatchVerify,
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
                    isEmailFlow ? 'Verify Email' : 'Continue',
                    style: TextStyle(
                      fontSize: screen.isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: screen.spacing),
        AuthTextButton(
          label: 'Resend Code',
          onPressed: () {
            if (!isLoading) {
              _dispatchResend();
            }
          },
        ),
      ],
    );
  }
}
