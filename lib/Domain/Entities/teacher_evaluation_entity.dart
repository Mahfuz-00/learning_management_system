import 'package:equatable/equatable.dart';

/// A student's rating of a teacher after a course finishes.
///
/// Manual §4.4: *"After a course finishes. **Anonymous to the teacher, but
/// admin can see who wrote what.**"*
///
/// The five criteria below map exactly to the `SubmitTeacherEvaluationDto`
/// fields in the live API: teachingQuality, subjectKnowledge, clarity, support
/// and overall. Each is scored 1–5.
class TeacherEvaluationEntity extends Equatable {
  final String courseId;
  final String teacherId;
  final int teachingQuality;
  final int subjectKnowledge;
  final int clarity;
  final int support;
  final int overall;
  final String? comment;

  const TeacherEvaluationEntity({
    required this.courseId,
    required this.teacherId,
    this.teachingQuality = 0,
    this.subjectKnowledge = 0,
    this.clarity = 0,
    this.support = 0,
    this.overall = 0,
    this.comment,
  });

  /// Average of the five criteria, 1–5.
  double get averageScore {
    final values = [teachingQuality, subjectKnowledge, clarity, support, overall];
    final nonZero = values.where((v) => v > 0).toList();
    if (nonZero.isEmpty) return 0;
    return nonZero.reduce((a, b) => a + b) / nonZero.length;
  }

  /// True when every required criterion has been scored.
  bool get isComplete =>
      teachingQuality > 0 &&
      subjectKnowledge > 0 &&
      clarity > 0 &&
      support > 0 &&
      overall > 0;

  /// Payload for `POST /api/TeacherEvaluation/submit`.
  Map<String, dynamic> toJson() => {
        'courseId': courseId,
        'teacherId': teacherId,
        'teachingQuality': teachingQuality,
        'subjectKnowledge': subjectKnowledge,
        'clarity': clarity,
        'support': support,
        'overall': overall,
        if (comment != null && comment!.isNotEmpty) 'comment': comment,
      };

  @override
  List<Object?> get props => [
        courseId,
        teacherId,
        teachingQuality,
        subjectKnowledge,
        clarity,
        support,
        overall,
        comment,
      ];
}

/// A live-class entry the student may be waiting for.
///
/// Used by the **Rule 3** "Coming soon" flow — a student can register interest
/// in an upcoming course's free live class.
class PreBookingEntity extends Equatable {
  final String id;
  final String courseId;
  final String? courseTitle;
  final String? studentName;
  final String? phone;
  final String? email;
  final DateTime? createdAt;
  final bool isContacted;

  const PreBookingEntity({
    required this.id,
    required this.courseId,
    this.courseTitle,
    this.studentName,
    this.phone,
    this.email,
    this.createdAt,
    this.isContacted = false,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseTitle,
        studentName,
        phone,
        email,
        createdAt,
        isContacted,
      ];
}