import 'package:dio/dio.dart';

/// Low-level exception thrown by the **data** layer.
///
/// The data layer is allowed to throw; the domain layer is not. Every
/// [Exception] defined here is caught inside a repository implementation and
/// translated into a domain [Failure] before it can reach a BLoC.
///
/// This separation is what allows the UI to never crash on a network error:
/// widgets only ever see `Either<Failure, T>`.
class ServerException implements Exception {
  /// Human-readable, already-localised-for-display message.
  final String message;

  /// HTTP status code when available (401, 403, 404, 429, 500…).
  final int? statusCode;

  /// Server-provided seconds to wait, parsed from the `Retry-After` header.
  /// Populated for HTTP 429 so the UI can count down the Rule 13 lockout.
  final int? retryAfterSeconds;

  const ServerException({
    required this.message,
    this.statusCode,
    this.retryAfterSeconds,
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when the device has no connectivity or a request times out.
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when a Hive box cannot be opened, read, or written.
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Local storage error']);

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown on 401/403 — an expired or invalid session.
class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Session expired. Please log in again.']);

  @override
  String toString() => 'AuthException: $message';
}

/// Central translator from [DioException] to the exceptions above.
///
/// **Why a single mapper:** the previous implementation duplicated error
/// handling in every data source and produced inconsistent messages. One
/// mapper guarantees every screen shows the same wording for the same
/// underlying problem.
class DioErrorMapper {
  DioErrorMapper._();

  /// Converts a Dio failure into a typed application exception.
  static Exception map(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'The connection timed out. Please check your internet and try again.',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'Could not reach Nirvoor servers. Check your internet connection.',
        );

      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');

      case DioExceptionType.badCertificate:
        return const NetworkException('Insecure connection refused');

      case DioExceptionType.badResponse:
        return _mapResponse(error);

      case DioExceptionType.unknown:
        return NetworkException(error.message ?? 'Unexpected network error');
    }
  }

  /// Maps an HTTP error response to a [ServerException] / [AuthException].
  static Exception _mapResponse(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;

    // ASP.NET Core sometimes returns the error as a plain string, sometimes as
    // a ProblemDetails object, and sometimes as a custom {message: ...} shape.
    String message = 'Something went wrong. Please try again.';
    if (data is Map) {
      message = (data['message'] ??
              data['error'] ??
              data['title'] ??
              data['detail'] ??
              message)
          .toString();
    } else if (data is String && data.trim().isNotEmpty) {
      message = data;
    }

    switch (status) {
      case 400:
        return ServerException(message: message, statusCode: 400);
      case 401:
        final path = error.requestOptions.path;
        final uriPath = error.requestOptions.uri.path;
        if (_isAuthRoute(path) || _isAuthRoute(uriPath)) {
          return AuthException(message);
        }
        return const AuthException('Your session has expired. Please log in again.');
      case 403:
        return const AuthException(
          'You do not have permission to do this. Contact support if this seems wrong.',
        );
      case 404:
        return const ServerException(
          message: 'This content is no longer available.',
          statusCode: 404,
        );

      // Rule 13 — the server allows 8 auth attempts per minute per IP.
      // A 429 here means "wait", NOT "wrong password". The UI must say so.
      case 429:
        return ServerException(
          message: message == 'Something went wrong. Please try again.'
              ? 'Too many attempts. Please wait a minute and try again.'
              : message,
          statusCode: 429,
          retryAfterSeconds: _parseRetryAfter(error.response),
        );

      case 500:
      case 502:
      case 503:
        return const ServerException(
          message: 'Nirvoor servers are busy right now. Please try again shortly.',
          statusCode: 500,
        );
      default:
        return ServerException(message: message, statusCode: status);
    }
  }

  /// True for auth routes — a 401 here means "bad credentials", not "expired
  /// session".
  static bool _isAuthRoute(String path) {
    return path.contains('Register/Login') ||
        path.contains('/api/Register/Login') ||
        path.contains('app/login') ||
        path.contains('Register/Register') ||
        path.contains('Register/Refresh') ||
        path.contains('PasswordReset');
  }

  /// Reads `Retry-After` (seconds). Falls back to the Rule 13 value of 60s.
  static int? _parseRetryAfter(Response? response) {
    final raw = response?.headers.value('retry-after');
    if (raw != null) {
      final parsed = int.tryParse(raw.trim());
      if (parsed != null) return parsed;
    }
    return 60;
  }
}