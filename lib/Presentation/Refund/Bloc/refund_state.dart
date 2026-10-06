import 'package:equatable/equatable.dart';

import '../../../Domain/Entities/refund_entity.dart';

/// Load status for the refund flow.
enum RefundLoadStatus { initial, loading, loaded, submitting, error }

/// State of the refund flow.
class RefundState extends Equatable {
  final RefundLoadStatus status;

  /// Whether the student may request a refund for the course in question.
  final RefundEligibilityEntity? eligibility;

  /// All refund requests the student has made.
  final List<RefundEntity> refunds;

  final String? errorMessage;

  /// One-shot success flag for a snackbar.
  final bool actionSucceeded;

  const RefundState({
    this.status = RefundLoadStatus.initial,
    this.eligibility,
    this.refunds = const [],
    this.errorMessage,
    this.actionSucceeded = false,
  });

  /// True when the student can currently submit a refund request.
  bool get canRequestRefund => eligibility?.isEligible ?? false;

  /// Requests still awaiting an admin decision.
  List<RefundEntity> get pendingRefunds =>
      refunds.where((r) => r.isPending).toList();

  /// Requests that have been resolved one way or another.
  List<RefundEntity> get resolvedRefunds =>
      refunds.where((r) => !r.isPending).toList();

  RefundState copyWith({
    RefundLoadStatus? status,
    RefundEligibilityEntity? eligibility,
    List<RefundEntity>? refunds,
    String? errorMessage,
    bool? actionSucceeded,
    bool clearError = false,
  }) {
    return RefundState(
      status: status ?? this.status,
      eligibility: eligibility ?? this.eligibility,
      refunds: refunds ?? this.refunds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionSucceeded: actionSucceeded ?? this.actionSucceeded,
    );
  }

  @override
  List<Object?> get props =>
      [status, eligibility, refunds, errorMessage, actionSucceeded];
}