import 'package:equatable/equatable.dart';

import '../../../Domain/Entities/ai_writing_entity.dart';
import '../../../Domain/Entities/exam_entity.dart';
import '../../../Domain/Entities/live_exam_entity.dart';
import '../../../Domain/Entities/practice_entity.dart';

/// Generic per-section load status.
///
/// Every sub-resource on the course hub keeps its own status so one failing
/// section never blanks the whole screen.
enum LoadStatus { initial, loading, loaded, error }

/// State for the learning surfaces (hub, exams, live exams, AI writing).
class LearningState extends Equatable {
  // ── Hub ───────────────────────────────────────────────────────────────
  final LoadStatus hubStatus;
  final List<ExamEntity> exams;
  final List<PracticeEntity> practiceFiles;
  final List<AiWritingTaskEntity> aiWritingTasks;
  final List<LiveExamEntity> availableLiveExams;

  // ── Course exam detail ────────────────────────────────────────────────
  final LoadStatus examStatus;
  final ExamEntity? activeExam;
  final Map<String, dynamic>? examQuestion;
  final List<ExamSubmissionEntity> examSubmissions;

  // ── Live exam ─────────────────────────────────────────────────────────
  final LoadStatus liveExamStatus;
  final LiveExamEntity? activeLiveExam;
  final List<LiveExamSubmissionEntity> liveExamSubmissions;

  // ── AI writing ────────────────────────────────────────────────────────
  final LoadStatus aiWritingStatus;
  final AiWritingTaskEntity? activeAiTask;
  final List<AiWritingSubmissionEntity> aiSubmissions;

  // ── Feedback ──────────────────────────────────────────────────────────
  /// Human-readable error for the most recent failed action.
  final String? errorMessage;

  /// Set to true when the last action succeeded, so the UI can show a
  /// confirmation snackbar exactly once.
  final bool actionSucceeded;

  /// True while a submit/upload action is in flight (shows a blocking spinner).
  final bool isSubmitting;

  const LearningState({
    this.hubStatus = LoadStatus.initial,
    this.exams = const [],
    this.practiceFiles = const [],
    this.aiWritingTasks = const [],
    this.availableLiveExams = const [],
    this.examStatus = LoadStatus.initial,
    this.activeExam,
    this.examQuestion,
    this.examSubmissions = const [],
    this.liveExamStatus = LoadStatus.initial,
    this.activeLiveExam,
    this.liveExamSubmissions = const [],
    this.aiWritingStatus = LoadStatus.initial,
    this.activeAiTask,
    this.aiSubmissions = const [],
    this.errorMessage,
    this.actionSucceeded = false,
    this.isSubmitting = false,
  });

  /// The four exam slots, ordered 1st → Final, for the Exam hub card.
  List<ExamEntity> get sortedExams {
    final sorted = [...exams];
    sorted.sort((a, b) => a.slot.value.compareTo(b.slot.value));
    return sorted;
  }

  /// Practice files only (the Practice hub card).
  List<PracticeEntity> get practiceOnly =>
      practiceFiles.where((p) => !p.isSuggestion).toList();

  /// Exam suggestions only (the Suggestion hub card).
  List<PracticeEntity> get suggestionsOnly =>
      practiceFiles.where((p) => p.isSuggestion).toList();

  /// Exams the student can act on right now.
  List<ExamEntity> get openExams => exams.where((e) => e.isOpen).toList();

  LearningState copyWith({
    LoadStatus? hubStatus,
    List<ExamEntity>? exams,
    List<PracticeEntity>? practiceFiles,
    List<AiWritingTaskEntity>? aiWritingTasks,
    List<LiveExamEntity>? availableLiveExams,
    LoadStatus? examStatus,
    ExamEntity? activeExam,
    Map<String, dynamic>? examQuestion,
    List<ExamSubmissionEntity>? examSubmissions,
    LoadStatus? liveExamStatus,
    LiveExamEntity? activeLiveExam,
    List<LiveExamSubmissionEntity>? liveExamSubmissions,
    LoadStatus? aiWritingStatus,
    AiWritingTaskEntity? activeAiTask,
    List<AiWritingSubmissionEntity>? aiSubmissions,
    String? errorMessage,
    bool? actionSucceeded,
    bool? isSubmitting,
    bool clearError = false,
    bool clearExamQuestion = false,
  }) {
    return LearningState(
      hubStatus: hubStatus ?? this.hubStatus,
      exams: exams ?? this.exams,
      practiceFiles: practiceFiles ?? this.practiceFiles,
      aiWritingTasks: aiWritingTasks ?? this.aiWritingTasks,
      availableLiveExams: availableLiveExams ?? this.availableLiveExams,
      examStatus: examStatus ?? this.examStatus,
      activeExam: activeExam ?? this.activeExam,
      examQuestion: clearExamQuestion ? null : (examQuestion ?? this.examQuestion),
      examSubmissions: examSubmissions ?? this.examSubmissions,
      liveExamStatus: liveExamStatus ?? this.liveExamStatus,
      activeLiveExam: activeLiveExam ?? this.activeLiveExam,
      liveExamSubmissions: liveExamSubmissions ?? this.liveExamSubmissions,
      aiWritingStatus: aiWritingStatus ?? this.aiWritingStatus,
      activeAiTask: activeAiTask ?? this.activeAiTask,
      aiSubmissions: aiSubmissions ?? this.aiSubmissions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionSucceeded: actionSucceeded ?? this.actionSucceeded,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        hubStatus,
        exams,
        practiceFiles,
        aiWritingTasks,
        availableLiveExams,
        examStatus,
        activeExam,
        examQuestion,
        examSubmissions,
        liveExamStatus,
        activeLiveExam,
        liveExamSubmissions,
        aiWritingStatus,
        activeAiTask,
        aiSubmissions,
        errorMessage,
        actionSucceeded,
        isSubmitting,
      ];
}