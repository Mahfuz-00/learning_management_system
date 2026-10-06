import '../../Domain/Entities/exam_entity.dart';

/// JSON mapping for [ExamEntity].
///
/// The backend declares no response schema for exam endpoints, so every field
/// is read defensively and the exam slot/status are normalised through the
/// domain enums.
class ExamModel extends ExamEntity {
  const ExamModel({
    required super.id,
    required super.courseId,
    required super.slot,
    required super.title,
    super.instruction,
    super.estimatedDate,
    super.durationMinutes,
    super.totalMarks,
    super.status,
    super.opensAt,
    super.deadline,
    super.hasQuestionFile,
    super.hasSubmitted,
    super.awardedMarks,
    super.feedback,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: (json['id'] ?? json['examId'] ?? '').toString(),
      courseId: (json['courseId'] ?? '').toString(),
      slot: ExamSlot.fromValue(_toInt(json['slot'])),
      title: (json['title'] ?? _defaultTitle(json['slot'])).toString(),
      instruction: json['instruction'] as String?,
      estimatedDate: _toDate(json['estimatedDate']),
      durationMinutes: _toNullableInt(json['durationMinutes']),
      totalMarks: _toNullableInt(json['totalMarks']),
      status: ExamStatus.fromString(json['status']?.toString()),
      opensAt: _toDate(json['opensAt'] ?? json['questionUploadedAt']),
      deadline: _toDate(json['deadline'] ?? json['estimatedDate']),
      hasQuestionFile: json['hasQuestionFile'] as bool? ??
          (json['questionFileUrl'] != null),
      hasSubmitted: json['hasSubmitted'] as bool? ?? false,
      awardedMarks: _toNullableInt(json['awardedMarks'] ?? json['marks']),
      feedback: json['feedback'] as String?,
    );
  }

  /// Falls back to the slot's canonical label when the server omits a title.
  static String _defaultTitle(dynamic slot) => ExamSlot.fromValue(_toInt(slot)).label;

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'slot': slot.value,
        'title': title,
        'instruction': instruction,
        'estimatedDate': estimatedDate?.toIso8601String(),
        'durationMinutes': durationMinutes,
        'totalMarks': totalMarks,
        'status': status.name,
        'opensAt': opensAt?.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'hasQuestionFile': hasQuestionFile,
        'hasSubmitted': hasSubmitted,
        'awardedMarks': awardedMarks,
        'feedback': feedback,
      };

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static int? _toNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}

/// JSON mapping for [ExamSubmissionEntity] (teacher grading queue).
class ExamSubmissionModel extends ExamSubmissionEntity {
  const ExamSubmissionModel({
    required super.id,
    required super.examId,
    required super.studentId,
    required super.studentName,
    super.studentEmail,
    super.answerFileUrl,
    super.submittedAt,
    super.marks,
    super.feedback,
    super.isGraded,
  });

  factory ExamSubmissionModel.fromJson(Map<String, dynamic> json) {
    return ExamSubmissionModel(
      id: (json['id'] ?? json['submissionId'] ?? '').toString(),
      examId: (json['examId'] ?? '').toString(),
      studentId: (json['studentId'] ?? json['userId'] ?? '').toString(),
      studentName: (json['studentName'] ?? json['fullName'] ?? 'Student').toString(),
      studentEmail: json['studentEmail'] as String?,
      answerFileUrl: (json['answerFileUrl'] ?? json['fileUrl']) as String?,
      submittedAt: _parseDate(json['submittedAt'] ?? json['createdAt']),
      marks: _parseInt(json['marks']),
      feedback: json['feedback'] as String?,
      isGraded: json['isGraded'] as bool? ?? (json['marks'] != null),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}