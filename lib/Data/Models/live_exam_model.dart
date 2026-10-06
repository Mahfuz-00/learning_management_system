import '../../Domain/Entities/live_exam_entity.dart';

/// JSON mapping for the Google-Forms-style live-class exam.
class LiveExamModel extends LiveExamEntity {
  const LiveExamModel({
    required super.id,
    required super.liveClassId,
    super.courseId,
    required super.title,
    super.description,
    super.durationMinutes,
    super.status,
    super.questions,
    super.totalPoints,
    super.hasSubmitted,
    super.awardedMarks,
  });

  factory LiveExamModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = (json['questions'] as List? ?? [])
        .whereType<Map>()
        .map((e) => LiveExamQuestionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // Prefer the server total; otherwise sum the question points locally so the
    // header can still show "Total marks".
    final declaredTotal = json['totalPoints'] ?? json['totalMarks'];
    final computedTotal = rawQuestions.fold<double>(0, (sum, q) => sum + q.points);

    return LiveExamModel(
      id: (json['id'] ?? json['examId'] ?? '').toString(),
      liveClassId: (json['liveClassId'] ?? '').toString(),
      courseId: json['courseId']?.toString(),
      title: (json['title'] ?? 'Live Exam').toString(),
      description: json['description'] as String?,
      durationMinutes: _parseInt(json['durationMinutes']),
      status: LiveExamStatus.fromString(json['status']?.toString()),
      questions: rawQuestions,
      totalPoints: declaredTotal != null
          ? _parseDouble(declaredTotal)
          : (rawQuestions.isEmpty ? null : computedTotal),
      hasSubmitted: json['hasSubmitted'] as bool? ?? false,
      awardedMarks: json['awardedMarks'] != null
          ? _parseDouble(json['awardedMarks'])
          : null,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  /// Shared numeric coercion used by the nested models below.
  static double parseDouble(dynamic v) => _parseDouble(v);

  /// Shared integer coercion used by the nested models below.
  static int? parseInt(dynamic v) => _parseInt(v);
}

/// JSON mapping for a single live-exam question.
class LiveExamQuestionModel extends LiveExamQuestionEntity {
  const LiveExamQuestionModel({
    required super.id,
    required super.type,
    required super.text,
    super.isRequired,
    super.points,
    super.order,
    super.fileUrl,
    super.options,
  });

  factory LiveExamQuestionModel.fromJson(Map<String, dynamic> json) {
    return LiveExamQuestionModel(
      id: (json['id'] ?? json['questionId'] ?? '').toString(),
      type: LiveExamQuestionType.fromValue(
        json['type'] is num ? (json['type'] as num).toInt() : int.tryParse('${json['type']}'),
      ),
      text: (json['text'] ?? json['question'] ?? '').toString(),
      isRequired: json['isRequired'] as bool? ?? false,
      points: LiveExamModel.parseDouble(json['points'] ?? 1),
      order: LiveExamModel.parseInt(json['order']) ?? 0,
      fileUrl: json['fileUrl'] as String?,
      options: (json['options'] as List? ?? [])
          .whereType<Map>()
          .map((e) => LiveExamOptionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// JSON mapping for a single multiple-choice option.
class LiveExamOptionModel extends LiveExamOptionEntity {
  const LiveExamOptionModel({
    required super.id,
    required super.text,
    super.isCorrect,
  });

  factory LiveExamOptionModel.fromJson(Map<String, dynamic> json) {
    return LiveExamOptionModel(
      id: (json['id'] ?? json['optionId'] ?? '').toString(),
      text: (json['text'] ?? json['optionText'] ?? '').toString(),
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }
}

/// JSON mapping for a student's live-exam submission (grading view).
class LiveExamSubmissionModel extends LiveExamSubmissionEntity {
  const LiveExamSubmissionModel({
    required super.id,
    required super.examId,
    required super.studentId,
    required super.studentName,
    super.studentEmail,
    super.submittedAt,
    super.autoMarks,
    super.manualMarks,
    super.finalMarks,
    super.feedback,
    super.isGraded,
    super.gradedAt,
  });

  factory LiveExamSubmissionModel.fromJson(Map<String, dynamic> json) {
    return LiveExamSubmissionModel(
      id: (json['id'] ?? json['submissionId'] ?? '').toString(),
      examId: (json['examId'] ?? '').toString(),
      studentId: (json['studentId'] ?? json['userId'] ?? '').toString(),
      studentName: (json['studentName'] ?? json['fullName'] ?? 'Student').toString(),
      studentEmail: json['studentEmail'] as String?,
      submittedAt: _parseDate(json['submittedAt'] ?? json['createdAt']),
      autoMarks: json['autoMarks'] != null
          ? LiveExamModel.parseDouble(json['autoMarks'])
          : null,
      manualMarks: json['manualMarks'] != null
          ? LiveExamModel.parseDouble(json['manualMarks'])
          : null,
      finalMarks: json['finalMarks'] != null
          ? LiveExamModel.parseDouble(json['finalMarks'])
          : (json['marks'] != null ? LiveExamModel.parseDouble(json['marks']) : null),
      feedback: json['feedback'] as String?,
      isGraded: json['isGraded'] as bool? ?? (json['finalMarks'] != null),
      gradedAt: _parseDate(json['gradedAt']),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}