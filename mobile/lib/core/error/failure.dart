class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() {
    final code = statusCode != null ? ' [code: $statusCode]' : '';
    return 'Failure: $message$code';
  }
}
