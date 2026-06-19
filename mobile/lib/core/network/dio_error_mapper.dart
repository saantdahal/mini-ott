import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import '../../shared/models/api_error_body.dart';

/// Extracts a server-provided message when the body is JSON.
String? _tryParseServerMessage(Object? data) {
  if (data is Map<String, dynamic>) {
    try {
      final body = ApiErrorBody.fromJson(data);
      final m = body.message?.trim();
      if (m != null && m.isNotEmpty) return m;
    } catch (_) {
      final raw = data['message'];
      if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    }
  }
  if (data is String && data.trim().isNotEmpty) {
    final t = data.trim();
    if (t.startsWith('{')) return null;
    if (t.length > 200) return null;
    return t;
  }
  return null;
}

String _friendlyStatusMessage(int? status) {
  if (status == null) return 'Something went wrong. Please try again.';
  switch (status) {
    case 400:
      return 'Invalid request. Please check your details and try again.';
    case 401:
      return 'Session expired or not authorized. Please sign in again.';
    case 403:
      return 'You do not have permission to do that.';
    case 404:
      return 'We could not find what you were looking for.';
    case 409:
      return 'This action conflicts with existing data. Please try again.';
    case 422:
      return 'Please check your information and try again.';
    case 429:
      return 'Too many attempts. Please wait a moment and try again.';
    default:
      if (status >= 500 && status < 600) {
        return 'Our servers are having trouble. Please try again shortly.';
      }
      return 'Something went wrong. Please try again.';
  }
}

/// Raw message from server when available (may be technical).
String messageFromDio(DioException e) {
  final fromBody = _tryParseServerMessage(e.response?.data);
  if (fromBody != null) return fromBody;
  return e.message ?? 'Request failed';
}

/// User-facing message: prefers server text when readable, otherwise maps by [DioExceptionType] / HTTP status.
String userFriendlyMessageFromDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionError:
      return 'No internet connection. Check your network and try again.';
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'The request timed out. Please try again.';
    case DioExceptionType.badCertificate:
      return 'Secure connection could not be established. Please try again later.';
    case DioExceptionType.cancel:
      return 'Request was cancelled.';
    case DioExceptionType.unknown:
      if (e.error is FormatException) {
        return 'Received an unexpected response. Please try again.';
      }
      break;
    case DioExceptionType.badResponse:
      break;
  }

  if (e.type == DioExceptionType.badResponse) {
    final status = e.response?.statusCode;
    final fromBody = _tryParseServerMessage(e.response?.data);
    if (fromBody != null && _isLikelyUserFacing(fromBody)) {
      return fromBody;
    }
    return _friendlyStatusMessage(status);
  }

  final fromBody = _tryParseServerMessage(e.response?.data);
  if (fromBody != null && _isLikelyUserFacing(fromBody)) return fromBody;

  return 'Something went wrong. Please try again.';
}

bool _isLikelyUserFacing(String message) {
  if (message.length > 280) return false;
  if (message.contains('Exception') || message.contains('Error:')) {
    return false;
  }
  return true;
}

AppException appExceptionFromDio(DioException e) {
  return AppException(
    message: userFriendlyMessageFromDio(e),
    statusCode: e.response?.statusCode,
    cause: e,
  );
}

/// Maps any thrown value to a safe string for UI (never raw [Object.toString] for unknown types).
String mapErrorToUserMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }
  if (error is DioException) {
    return userFriendlyMessageFromDio(error);
  }
  return 'Something went wrong. Please try again.';
}
