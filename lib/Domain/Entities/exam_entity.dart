import 'package:equatable/equatable.dart';

/// The four course-exam slots defined by the User Manual (§4.4):
/// *"Four slots: 1st, 2nd, 3rd, Final."*
///
/// The backend sends `slot` as an `int32` with no documented meaning, so this
/// enum is the single place that maps the wire value to something readable.
enum ExamSlot {
  first(1, '1st Exam'),
  second(2, '2nd Exam'),
  third(3, '3rd Exam'),
  finalExam(4, 'Final Exam');

  const ExamSlot(this.value, this.label);

  /// Wire value used by `CreateExamDTO.slot`.
  final int value;

  /// Human label shown in the hub's Exam card.
  final String label;

  /// Resolves a raw wire value, defaulting to [ExamSlot.first].
  static ExamSlot fromValue(int? value) {
    return ExamSlot.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ExamSlot.first,
    );
  }
}

/// Lifecycle of a single course exam.
///
/// Manual §4.4: *"The exam window **opens when the teacher uploads the question
/// file**, and everyone gets the same clock."*
enum ExamStatus {
  /// The teacher has not uploaded the question file yet.
  locked,

  /// Question file uploaded — students may download and submit.
  open,

  /// The deadline has passed.
  closed;

  /// Parses the server status string, tolerating casing and synonyms.
  static ExamStatus fromString(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'open':
      case 'active':
      case 'available':
        return ExamStatus.open;
      case 'closed':
      case 'expired':
      case 'ended':
        return ExamStatus.closed;
      default:
        return ExamStatus.locked;
    }
  }
}

/// A course exam belonging to one of the four slots.
///
/// A teacher creates it and uploads a question file; the upload is what opens
/// the exam for students. Students then download the question, write their
/// answer, and upload an answer file before the deadline.
class ExamEntity extends Equatable {
  final String id;
  final String courseId;
  final ExamSlot slot;
  final String title;
  final String? instruction;

  /// Teacher's estimated date for the exam.
  final DateTime? estimatedDate;

  /// How long students have once it opens.
  final int? durationMinutes;

  final int? totalMarks;

  /// Server-computed lifecycle state. Drives the Exam hub card.
  final ExamStatus status;

  /// When the exam became available (i.e. question file upload time).
  final DateTime? opensAt;

  /// Hard deadline for answer submission.
  final DateTime? deadline;

  /// True once the teacher has uploaded the question paper.
  final bool hasQuestionFile;

  /// Whether the current student has already submitted an answer file.
  final bool hasSubmitted;

  /// The mark awarded once the teacher has graded the submission.
  final int? awardedMarks;

  final String? feedback;

  const ExamEntity({
    required this.id,
    required this.courseId,
    required this.slot,
    required this.title,
    this.instruction,
    this.estimatedDate,
    this.durationMinutes,
    this.totalMarks,
    this.status = ExamStatus.locked,
    this.opensAt,
    this.deadline,
    this.hasQuestionFile = false,
    this.hasSubmitted = false,
    this.awardedMarks,
    this.feedback,
  });

  /// True when a student can currently open and answer this exam.
  bool get isOpen => status == ExamStatus.open;

  /// True when the exam is still awaiting the teacher's question upload.
  bool get isLocked => status == ExamStatus.locked;

  /// True when the deadline has passed.
  bool get isClosed => status == ExamStatus.closed;

  /// True when the student can still act on this exam.
  bool get isActionable => isOpen && !hasSubmitted;

  @override
  List<Object?> get props => [
        id,
        courseId,
        slot,
        title,
        instruction,
        estimatedDate,
        durationMinutes,
        totalMarks,
        status,
        opensAt,
        deadline,
        hasQuestionFile,
        hasSubmitted,
        awardedMarks,
        feedback,
      ];
}

/// A single student submission awaiting the teacher's mark.
///
/// Manual §5.2: *"Download each student's answer file, type a mark and
/// feedback."*
class ExamSubmissionEntity extends Equatable {
  final String id;
  final String examId;
  final String studentId;
  final String studentName;
  final String? studentEmail;
  final String? answerFileUrl;
  final DateTime? submittedAt;
  final int? marks;
  final String? feedback;

  /// True once the teacher has recorded a mark.
  final bool isGraded;

  const ExamSubmissionEntity({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.studentName,
    this.studentEmail,
    this.answerFileUrl,
    this.submittedAt,
    this.marks,
    this.feedback,
    this.isGraded = false,
  });

  @override
  List<Object?> get props => [
        id,
        examId,
        studentId,
        studentName,
        studentEmail,
        answerFileUrl,
        submittedAt,
        marks,
        feedback,
        isGraded,
      ];
}