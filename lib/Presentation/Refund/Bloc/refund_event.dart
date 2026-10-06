import 'package:equatable/equatable.dart';

/// Base class for refund events.
abstract class RefundEvent extends Equatable {
  const RefundEvent();

  @override
  List<Object?> get props => [];
}

/// Checks whether the student may request a refund for a course, and why not.
class LoadRefundEligibility extends RefundEvent {
  final String courseId;
  const LoadRefundEligibility(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

/// Submits a refund request with the student's reason.
class RequestRefund extends RefundEvent {
  final String courseId;
  final String reason;
  const RequestRefund({required this.courseId, required this.reason});

  @override
  List<Object?> get props => [courseId, reason];
}

/// Loads the student's refund requests and their outcomes.
class LoadMyRefunds extends RefundEvent {
  const LoadMyRefunds();
}

/// Withdraws a pending refund request.
class CancelRefund extends RefundEvent {
  final String refundId;
  const CancelRefund(this.refundId);

  @override
  List<Object?> get props => [refundId];
}

/// Clears the one-shot success flag after the UI shows its snackbar.
class ClearRefundFeedback extends RefundEvent {
  const ClearRefundFeedback();
}