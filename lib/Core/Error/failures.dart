import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// The server responded, but with an error status (4xx / 5xx).
class ServerFailure extends Failure {
  /// HTTP status code, when known.
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No Internet Connection']) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// **Rule 13** — the server rate-limiter rejected the request.
///
/// This is deliberately its own failure type because the correct UI response is
/// a *countdown*, not an error. The User Manual is explicit: while testing you
/// will hit the 8-attempts-per-minute limit and the site "will start refusing
/// you with an error even though your password is right."
///
/// If this were collapsed into [AuthFailure] the login screen would wrongly say
/// "incorrect password", which is exactly the confusion the manual warns about.
class RateLimitFailure extends Failure {
  /// Seconds the user must wait before retrying.
  final int retryAfterSeconds;

  const RateLimitFailure({
    this.retryAfterSeconds = 60,
    String message =
        'Too many attempts. Please wait a minute before trying again.',
  }) : super(message);

  @override
  List<Object> get props => [message, retryAfterSeconds];
}

/// The requested content exists but is not available to this user.
///
/// Used for **Rule 2** (a course whose start date has passed is hidden from
/// students who were never enrolled, even via a direct link).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'This content is no longer available.']);
}

/// The action requires an active enrollment the user does not have.
class EnrollmentRequiredFailure extends Failure {
  const EnrollmentRequiredFailure([
    super.message = 'Please enroll in this course to continue.',
  ]);
}

/// The user's account is awaiting teacher approval (Manual §5.1).
class PendingApprovalFailure extends Failure {
  const PendingApprovalFailure([
    super.message = 'Your teacher account is waiting for admin approval.',
  ]);
}
