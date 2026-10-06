import '../../Domain/Entities/teacher_evaluation_entity.dart';
import 'json_utils.dart';

/// JSON mapping for a teacher evaluation (Manual §4.4).
class TeacherEvaluationModel extends TeacherEvaluationEntity {
  const TeacherEvaluationModel({
    required super.courseId,
    required super.teacherId,
    super.teachingQuality,
    super.subjectKnowledge,
    super.clarity,
    super.support,
    super.overall,
    super.comment,
  });

  factory TeacherEvaluationModel.fromJson(Map<String, dynamic> json) {
    return TeacherEvaluationModel(
      courseId: JsonUtils.toStringValue(json['courseId']),
      teacherId: JsonUtils.toStringValue(json['teacherId']),
      teachingQuality: JsonUtils.toInt(json['teachingQuality']),
      subjectKnowledge: JsonUtils.toInt(json['subjectKnowledge']),
      clarity: JsonUtils.toInt(json['clarity']),
      support: JsonUtils.toInt(json['support']),
      overall: JsonUtils.toInt(json['overall']),
      comment: JsonUtils.toStringOrNull(json['comment']),
    );
  }
}

/// JSON mapping for a pre-booking (Rule 3 — "Coming soon" courses).
class PreBookingModel extends PreBookingEntity {
  const PreBookingModel({
    required super.id,
    required super.courseId,
    super.courseTitle,
    super.studentName,
    super.phone,
    super.email,
    super.createdAt,
    super.isContacted,
  });

  factory PreBookingModel.fromJson(Map<String, dynamic> json) {
    return PreBookingModel(
      id: JsonUtils.toStringValue(json['id']),
      courseId: JsonUtils.toStringValue(json['courseId']),
      courseTitle: JsonUtils.toStringOrNull(json['courseTitle']),
      studentName: JsonUtils.toStringOrNull(json['studentName'] ?? json['fullName']),
      phone: JsonUtils.toStringOrNull(json['phone'] ?? json['mobileNumber']),
      email: JsonUtils.toStringOrNull(json['email']),
      createdAt: JsonUtils.toDate(json['createdAt']),
      isContacted: JsonUtils.toBool(json['isContacted']),
    );
  }
}