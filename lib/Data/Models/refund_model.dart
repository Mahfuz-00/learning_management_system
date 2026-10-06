import '../../Domain/Entities/refund_entity.dart';
import 'json_utils.dart';

/// JSON mapping for refund eligibility.
class RefundEligibilityModel extends RefundEligibilityEntity {
  const RefundEligibilityModel({
    required super.isEligible,
    super.reason,
    super.currentStatus,
    super.refundableAmount,
  });

  factory RefundEligibilityModel.fromJson(Map<String, dynamic> json) {
    return RefundEligibilityModel(
      isEligible: JsonUtils.toBool(json['isEligible'] ?? json['eligible']),
      reason: JsonUtils.toStringOrNull(json['reason'] ?? json['message']),
      currentStatus: RefundStatus.fromString(json['status']?.toString()),
      refundableAmount: JsonUtils.toDoubleOrNull(json['refundableAmount']),
    );
  }
}

/// JSON mapping for a student's refund request.
class RefundModel extends RefundEntity {
  const RefundModel({
    required super.id,
    required super.courseId,
    required super.courseTitle,
    required super.reason,
    super.status,
    super.requestedAt,
    super.resolvedAt,
    super.adminNote,
    super.refundedAmount,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      id: JsonUtils.toStringValue(json['id'] ?? json['refundId']),
      courseId: JsonUtils.toStringValue(json['courseId']),
      courseTitle: JsonUtils.toStringValue(
        json['courseTitle'] ?? json['courseName'],
        fallback: 'Course',
      ),
      reason: JsonUtils.toStringValue(json['reason']),
      status: RefundStatus.fromString(json['status']?.toString()),
      requestedAt: JsonUtils.toDate(json['requestedAt'] ?? json['createdAt']),
      resolvedAt: JsonUtils.toDate(json['resolvedAt'] ?? json['updatedAt']),
      adminNote: JsonUtils.toStringOrNull(json['adminNote'] ?? json['note']),
      refundedAmount: JsonUtils.toDoubleOrNull(json['refundedAmount'] ?? json['amount']),
    );
  }
}