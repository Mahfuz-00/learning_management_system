import 'package:equatable/equatable.dart';

/// Lifecycle of a refund request.
///
/// **Rule 9** — *"When admin approves a refund, the enrolment is **deleted**,
/// not marked as cancelled. The student loses access immediately."* and
/// *"There is an **Undo** button on an approved refund."*
///
/// [reversed] models that Undo — it is the only way in the whole system to put
/// a student back into a course without paying again.
enum RefundStatus {
  none,

  /// Student has asked; sitting in the admin queue.
  requested,

  /// Admin approved — enrollment deleted, access revoked.
  approved,

  /// Admin rejected the request.
  rejected,

  /// Admin pressed Undo on an approval — enrollment restored.
  reversed,

  /// Student withdrew the request before it was actioned.
  cancelled;

  /// Parses a server status string tolerantly.
  static RefundStatus fromString(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'requested':
      case 'pending':
        return RefundStatus.requested;
      case 'approved':
        return RefundStatus.approved;
      case 'rejected':
        return RefundStatus.rejected;
      case 'reversed':
      case 'undone':
        return RefundStatus.reversed;
      case 'cancelled':
      case 'canceled':
        return RefundStatus.cancelled;
      default:
        return RefundStatus.none;
    }
  }
}

/// Whether a student is allowed to request a refund for a course, and why not
/// if they are not.
class RefundEligibilityEntity extends Equatable {
  final bool isEligible;
  final String? reason;

  /// Current refund state for this course, so the UI can disable the button.
  final RefundStatus currentStatus;

  /// Amount that would be refunded, in Taka.
  final double? refundableAmount;

  const RefundEligibilityEntity({
    required this.isEligible,
    this.reason,
    this.currentStatus = RefundStatus.none,
    this.refundableAmount,
  });

  @override
  List<Object?> get props => [isEligible, reason, currentStatus, refundableAmount];
}

/// A student's refund request and its outcome.
class RefundEntity extends Equatable {
  final String id;
  final String courseId;
  final String courseTitle;
  final String reason;
  final RefundStatus status;
  final DateTime? requestedAt;
  final DateTime? resolvedAt;

  /// Admin's note explaining a rejection.
  final String? adminNote;

  /// The amount recorded as refunded, in Taka.
  ///
  /// **Rule 9 reminder:** *"the system records the refund. It does not move any
  /// money. Someone must send the money back by hand."* The UI must say so.
  final double? refundedAmount;

  const RefundEntity({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.reason,
    this.status = RefundStatus.requested,
    this.requestedAt,
    this.resolvedAt,
    this.adminNote,
    this.refundedAmount,
  });

  /// True while the request is still in the admin queue.
  bool get isPending => status == RefundStatus.requested;

  /// True when the student may still withdraw the request.
  bool get isCancellable => status == RefundStatus.requested;

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseTitle,
        reason,
        status,
        requestedAt,
        resolvedAt,
        adminNote,
        refundedAmount,
      ];
}