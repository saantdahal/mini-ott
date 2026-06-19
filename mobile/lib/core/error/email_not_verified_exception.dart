import 'app_exception.dart';

/// Thrown when login fails because the account email is not verified (HTTP 403).
class EmailNotVerifiedException extends AppException {
  const EmailNotVerifiedException({
    required this.email,
    required super.message,
    super.statusCode = 403,
  });

  final String email;
}
