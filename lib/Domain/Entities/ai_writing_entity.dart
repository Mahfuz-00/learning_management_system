import 'package:equatable/equatable.dart';

/// An AI-marked handwriting task (Manual §4.4).
///
/// *"Student uploads a handwritten answer photo. The AI reads the handwriting
/// and gives a mark out of 100 with feedback. Admin can overwrite the mark
/// afterwards. Multiple attempts allowed — the last one counts."*
class AiWritingTaskEntity extends Equatable {
  final String id;
  final String courseId;
  final String title;

  /// Task category, e.g. "Essay" / "Creative Writing".
  final String? type;
  final String? instructions;

  /// Suggested topics the student may choose from.
  final List<String> topics;

  /// Only published tasks are visible to students.
  final bool isPublished;

  /// Marks are always out of 100 per the manual.
  final int maxMarks;

  /// How many times the student has already submitted.
  final int attemptCount;

  /// The mark of the **latest** attempt — "the last one counts".
  final int? latestMark;

  /// Feedback for the latest attempt.
  final String? latestFeedback;

  /// True once the student has submitted at least once.
  final bool hasSubmitted;

  const AiWritingTaskEntity({
    required this.id,
    required this.courseId,
    required this.title,
    this.type,
    this.instructions,
    this.topics = const [],
    this.isPublished = true,
    this.maxMarks = 100,
    this.attemptCount = 0,
    this.latestMark,
    this.latestFeedback,
    this.hasSubmitted = false,
  });

  /// True when the student may submit again (attempts are unlimited).
  bool get canAttemptAgain => isPublished;

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        type,
        instructions,
        topics,
        isPublished,
        maxMarks,
        attemptCount,
        latestMark,
        latestFeedback,
        hasSubmitted,
      ];
}

/// A single submission of a handwriting photo.
class AiWritingSubmissionEntity extends Equatable {
  final String id;
  final String taskId;
  final String studentId;
  final String studentName;

  /// 1-based attempt number.
  final int attemptNumber;

  /// True for the attempt whose mark currently counts.
  final bool isLatest;

  /// The mark produced by the AI handwriting reader.
  final int? aiMark;

  /// The mark that finally counts. Differs from [aiMark] when an admin has
  /// overwritten it.
  final int? finalMark;

  final String? feedback;

  /// URL of the uploaded handwritten answer image.
  final String? fileUrl;

  final DateTime? submittedAt;

  /// Name of the admin who overwrote the AI mark, if any.
  final String? overriddenBy;

  const AiWritingSubmissionEntity({
    required this.id,
    required this.taskId,
    required this.studentId,
    required this.studentName,
    this.attemptNumber = 1,
    this.isLatest = true,
    this.aiMark,
    this.finalMark,
    this.feedback,
    this.fileUrl,
    this.submittedAt,
    this.overriddenBy,
  });

  /// True when a human changed the AI's mark.
  bool get wasOverridden => overriddenBy != null && overriddenBy!.isNotEmpty;

  /// The mark to display.
  int? get displayMark => finalMark ?? aiMark;

  @override
  List<Object?> get props => [
        id,
        taskId,
        studentId,
        studentName,
        attemptNumber,
        isLatest,
        aiMark,
        finalMark,
        feedback,
        fileUrl,
        submittedAt,
        overriddenBy,
      ];
}