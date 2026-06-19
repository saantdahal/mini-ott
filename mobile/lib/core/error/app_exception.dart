class AppException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const AppException({required this.message, this.statusCode, this.cause});

  @override
  String toString() {
    final code = statusCode != null ? ' [code: $statusCode]' : '';
    return 'AppException$message$code';
  }
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network error occurred',
    super.statusCode,
    super.cause,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized request',
    super.statusCode,
    super.cause,
  });
}

class UnknownException extends AppException {
  const UnknownException({
    super.message = 'Unexpected error occurred',
    super.statusCode,
    super.cause,
  });
}
