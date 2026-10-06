import 'package:equatable/equatable.dart';

/// Question kinds supported by the Google-Forms-style live exam builder.
///
/// The backend sends `type` as an `int32`; this enum is the single mapping.
enum LiveExamQuestionType {
  /// Single-choice question rendered as radio buttons.
  multipleChoice(0),

  /// Free-text answer typed in the browser.
  shortAnswer(1),

  /// Long free-text answer.
  paragraph(2),

  /// A file the student must upload (Manual §4.4: "file answers from the
  /// student").
  fileUpload(3);

  const LiveExamQuestionType(this.value);

  final int value;

  /// Resolves a raw wire value, defaulting to [LiveExamQuestionType.shortAnswer].
  static LiveExamQuestionType fromValue(int? value) {
    return LiveExamQuestionType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => LiveExamQuestionType.shortAnswer,
    );
  }
}

/// Lifecycle of a live-class exam.
///
/// Only a teacher may create, publish, close or delete one — **Rule 10**:
/// *"Only the teacher can create and mark a live-class exam. Admin can only
/// look."* Admin has read-only access to the responses page.
enum LiveExamStatus {
  /// Built by the teacher but not yet released to students.
  draft,

  /// Students can open and answer it.
  published,

  /// No longer accepting answers.
  closed;

  static LiveExamStatus fromString(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'published':
      case 'active':
      case 'open':
        return LiveExamStatus.published;
      case 'closed':
      case 'ended':
        return LiveExamStatus.closed;
      default:
        return LiveExamStatus.draft;
    }
  }
}

/// A single option belonging to a multiple-choice live-exam question.
class LiveExamOptionEntity extends Equatable {
  final String id;
  final String text;

  /// True when this option is the correct answer. Only ever true for a teacher
  /// fetching the *manage* view — students receive options with this stripped.
  final bool isCorrect;

  const LiveExamOptionEntity({
    required this.id,
    required this.text,
    this.isCorrect = false,
  });

  @override
  List<Object?> get props => [id, text, isCorrect];
}

/// One question in a live-class exam.
class LiveExamQuestionEntity extends Equatable {
  final String id;
  final LiveExamQuestionType type;
  final String text;

  /// Whether the student must answer this question.
  final bool isRequired;

  /// Marks available for this question.
  final double points;

  /// Display order set by the teacher.
  final int order;

  /// Optional attachment the teacher added (Manual §4.4: "Can include a file
  /// the teacher attached").
  final String? fileUrl;

  final List<LiveExamOptionEntity> options;

  const LiveExamQuestionEntity({
    required this.id,
    required this.type,
    required this.text,
    this.isRequired = false,
    this.points = 1,
    this.order = 0,
    this.fileUrl,
    this.options = const [],
  });

  @override
  List<Object?> get props =>
      [id, type, text, isRequired, points, order, fileUrl, options];
}

/// A Google-Forms-style exam attached to a live class.
class LiveExamEntity extends Equatable {
  final String id;
  final String liveClassId;
  final String? courseId;
  final String title;
  final String? description;
  final int? durationMinutes;
  final LiveExamStatus status;
  final List<LiveExamQuestionEntity> questions;

  /// Total marks available (sum of question points, when the server sends it).
  final double? totalPoints;

  /// Whether the current student has already submitted.
  final bool hasSubmitted;

  /// The mark awarded after grading.
  final double? awardedMarks;

  const LiveExamEntity({
    required this.id,
    required this.liveClassId,
    this.courseId,
    required this.title,
    this.description,
    this.durationMinutes,
    this.status = LiveExamStatus.draft,
    this.questions = const [],
    this.totalPoints,
    this.hasSubmitted = false,
    this.awardedMarks,
  });

  /// True when students may currently open the exam.
  bool get isPublished => status == LiveExamStatus.published;

  /// True when the teacher is still building it.
  bool get isDraft => status == LiveExamStatus.draft;

  /// True when it is no longer accepting answers.
  bool get isClosed => status == LiveExamStatus.closed;

  @override
  List<Object?> get props => [
        id,
        liveClassId,
        courseId,
        title,
        description,
        durationMinutes,
        status,
        questions,
        totalPoints,
        hasSubmitted,
        awardedMarks,
      ];
}

/// One student's answers to a live-class exam.
///
/// Manual §5.2: answers are *"auto-marked where possible, manual marks where
/// needed"* — hence the separate auto/manual/final mark fields.
class LiveExamSubmissionEntity extends Equatable {
  final String id;
  final String examId;
  final String studentId;
  final String studentName;
  final String? studentEmail;
  final DateTime? submittedAt;

  /// Marks awarded automatically (multiple choice / exact-match answers).
  final double? autoMarks;

  /// Marks awarded by the teacher.
  final double? manualMarks;

  /// The mark that finally counts.
  final double? finalMarks;

  final String? feedback;
  final bool isGraded;
  final DateTime? gradedAt;

  const LiveExamSubmissionEntity({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.studentName,
    this.studentEmail,
    this.submittedAt,
    this.autoMarks,
    this.manualMarks,
    this.finalMarks,
    this.feedback,
    this.isGraded = false,
    this.gradedAt,
  });

  /// True when the teacher still needs to review this submission.
  bool get needsManualGrading => !isGraded;

  @override
  List<Object?> get props => [
        id,
        examId,
        studentId,
        studentName,
        studentEmail,
        submittedAt,
        autoMarks,
        manualMarks,
        finalMarks,
        feedback,
        isGraded,
        gradedAt,
      ];
}