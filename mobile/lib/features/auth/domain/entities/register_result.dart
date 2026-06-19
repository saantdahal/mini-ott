/// Outcome of user registration against the server.
sealed class RegisterResult {
  const RegisterResult();
}

/// Email signup succeeded; user must verify OTP before logging in.
class RegisterNeedsEmailVerification extends RegisterResult {
  const RegisterNeedsEmailVerification({
    required this.email,
    required this.message,
  });

  final String email;
  final String message;
}
