import 'package:email_validator/email_validator.dart';

class Validators {
  const Validators._();

  static bool isEmail(String value) {
    return EmailValidator.validate(value.trim());
  }

  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }

  static bool hasMinLength(String value, int minLength) {
    return value.trim().length >= minLength;
  }

  static bool isStrongPassword(String value) {
    final trimmed = value.trim();

    if (trimmed.length < 8) {
      return false;
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(trimmed);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(trimmed);
    final hasNumber = RegExp(r'\d').hasMatch(trimmed);

    return hasUppercase && hasLowercase && hasNumber;
  }
}
