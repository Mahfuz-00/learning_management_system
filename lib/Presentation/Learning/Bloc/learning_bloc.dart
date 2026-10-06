import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Domain/Repositories/learning_repository.dart';
import 'learning_event.dart';
import 'learning_state.dart';

/// Orchestrates every learning surface a student or teacher touches inside an
/// enrolled course: the hub, the four course exams, live-class exams, AI
/// writing and practice files.
///
/// The BLoC owns no business rules of its own — it loads data through the
/// repository and exposes load status per section so the UI can render
/// independent loading/error states.
class LearningBloc extends Bloc<LearningEvent, LearningState> {
  final LearningRepository repository;

  LearningBloc({required this.repository}) : super(const LearningState()) {
    // Hub
    on<LoadCourseHub>(_onLoadCourseHub);

    // Course exams
    on<LoadCourseExams>(_onLoadCourseExams);
    on<LoadExamQuestion>(_onLoadExamQuestion);
    on<SubmitExamAnswer>(_onSubmitExamAnswer);
    on<CreateExamRequested>(_onCreateExam);
    on<UploadExamQuestionRequested>(_onUploadExamQuestion);
    on<LoadExamSubmissions>(_onLoadExamSubmissions);
    on<GradeExamSubmissionRequested>(_onGradeExamSubmission);

    // Live exams
    on<LoadLiveExam>(_onLoadLiveExam);
    on<LoadLiveExamManage>(_onLoadLiveExamManage);
    on<SaveLiveExamRequested>(_onSaveLiveExam);
    on<PublishLiveExamRequested>(_onPublishLiveExam);
    on<TakeLiveExamRequested>(_onTakeLiveExam);
    on<SubmitLiveExamRequested>(_onSubmitLiveExam);
    on<LoadLiveExamSubmissions>(_onLoadLiveExamSubmissions);
    on<GradeLiveExamRequested>(_onGradeLiveExam);

    // AI writing
    on<LoadAiWritingTasks>(_onLoadAiWritingTasks);
    on<LoadAiWritingTask>(_onLoadAiWritingTask);
    on<SubmitAiWritingRequested>(_onSubmitAiWriting);

    // Practice
    on<LoadPracticeFiles>(_onLoadPracticeFiles);
  }

  // ── Hub ────────────────────────────────────────────────────────────────

  /// Loads the five hub cards for one course.
  ///
  /// Manual §4.3 describes the hub as: Practice, Live Class, Recordings, Exam
  /// and Suggestion. The live-class and recording data is loaded by
  /// `CourseBloc` (it owns live classes), so this handler fetches only what
  /// this BLoC owns: exams, practice/suggestion files, AI writing tasks.
  Future<void> _onLoadCourseHub(
    LoadCourseHub event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(hubStatus: LoadStatus.loading, clearError: true));

    final examsResult = await repository.getExamsByCourse(event.courseId);
    final practiceResult = await repository.getPracticeByCourse(event.courseId);
    final aiResult = await repository.getAiWritingByCourse(event.courseId);

    String? error;

    final exams = examsResult.fold(
      (failure) {
        error = failure.message;
        return state.exams;
      },
      (value) => value,
    );

    final practice = practiceResult.fold(
      (failure) {
        error ??= failure.message;
        return state.practiceFiles;
      },
      (value) => value,
    );

    final aiTasks = aiResult.fold(
      (failure) {
        error ??= failure.message;
        return state.aiWritingTasks;
      },
      (value) => value,
    );

    emit(state.copyWith(
      hubStatus: error != null ? LoadStatus.error : LoadStatus.loaded,
      exams: exams,
      practiceFiles: practice,
      aiWritingTasks: aiTasks,
      errorMessage: error,
    ));
  }

  // ── Course exams ───────────────────────────────────────────────────────

  Future<void> _onLoadCourseExams(
    LoadCourseExams event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(examStatus: LoadStatus.loading, clearError: true));
    final result = await repository.getExamsByCourse(event.courseId);
    result.fold(
      (failure) => emit(state.copyWith(
        examStatus: LoadStatus.error,
        errorMessage: failure.message,
      )),
      (exams) => emit(state.copyWith(
        examStatus: LoadStatus.loaded,
        exams: exams,
      )),
    );
  }

  Future<void> _onLoadExamQuestion(
    LoadExamQuestion event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(examStatus: LoadStatus.loading, clearError: true));
    final result = await repository.getExamQuestion(event.examId);
    result.fold(
      (failure) => emit(state.copyWith(
        examStatus: LoadStatus.error,
        errorMessage: failure.message,
      )),
      (question) => emit(state.copyWith(
        examStatus: LoadStatus.loaded,
        examQuestion: question,
      )),
    );
  }

  /// Uploads the student's answer file.
  ///
  /// Manual §4.4: *"Download the question, write the answer, upload your answer
  /// file before the deadline."*
  Future<void> _onSubmitExamAnswer(
    SubmitExamAnswer event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, actionSucceeded: false));
    final result = await repository.submitExamAnswer(event.examId, event.file);
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(isSubmitting: false, actionSucceeded: true));
        // Refresh so the hub immediately reflects "submitted".
        add(LoadCourseExams(event.examId));
      },
    );
  }

  Future<void> _onCreateExam(
    CreateExamRequested event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, actionSucceeded: false));
    final result = await repository.createExam(event.data);
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (exam) => emit(state.copyWith(
        isSubmitting: false,
        actionSucceeded: true,
        activeExam: exam,
      )),
    );
  }

  /// Uploads the question paper.
  ///
  /// **This is the action that OPENS the exam** (Manual §4.4): *"The exam window
  /// opens when the teacher uploads the question file."*
  Future<void> _onUploadExamQuestion(
    UploadExamQuestionRequested event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, actionSucceeded: false));
    final result = await repository.uploadExamQuestion(event.examId, event.file);
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(isSubmitting: false, actionSucceeded: true)),
    );
  }

  Future<void> _onLoadExamSubmissions(
    LoadExamSubmissions event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(examStatus: LoadStatus.loading, clearError: true));
    final result = await repository.getExamSubmissions(event.examId);
    result.fold(
      (failure) => emit(state.copyWith(
        examStatus: LoadStatus.error,
        errorMessage: failure.message,
      )),
      (submissions) => emit(state.copyWith(
        examStatus: LoadStatus.loaded,
        examSubmissions: submissions,
      )),
    );
  }

  Future<void> _onGradeExamSubmission(
    GradeExamSubmissionRequested event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, actionSucceeded: false));
    final result = await repository.gradeExamSubmission(
      event.submissionId,
      event.marks,
      event.feedback,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(isSubmitting: false, actionSucceeded: true)),
    );
  }

  // ── Live exams ─────────────────────────────────────────────────────────

  Future<void> _onLoadLiveExam(
    LoadLiveExam event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(liveExamStatus: LoadStatus.loading, clearError: true));
    final result = await repository.getLiveExamForClass(event.liveClassId);
    result.fold(
      (failure) => emit(state.copyWith(
        liveExamStatus: LoadStatus.error,
        errorMessage: failure.message,
      )),
      (exam) => emit(state.copyWith(
        liveExamStatus: LoadStatus.loaded,
        activeLiveExam: exam,
      )),
    );
  }

  Future<void> _onLoadLiveExamManage(
    LoadLiveExamManage event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(liveExamStatus: LoadStatus.loading, clearError: true));
    final result = await repository.getLiveExamManage(event.liveClassId);
    result.fold(
      (failure) => emit(state.copyWith(
        liveExamStatus: LoadStatus.error,
        errorMessage: failure.message,
      )),
      (exam) => emit(state.copyWith(
        liveExamStatus: LoadStatus.loaded,
        activeLiveExam: exam,
      )),
    );
  }

  Future<void> _onSaveLiveExam(
    SaveLiveExamRequested event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, actionSucceeded: false));
    final result = await repository.saveLiveExam(event.liveClassId, event.data);
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (exam) => emit(state.copyWith(
        isSubmitting: false,
        actionSucceeded: true,
        activeLiveExam: exam,
      )),
    );
  }

  Future<void> _onPublishLiveExam(
    PublishLiveExamRequested event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, actionSucceeded: false));
    final result = await repository.publishLiveExam(event.examId);
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(isSubmitting: false, actionSucceeded: true)),
    );
  }

  Future<void> _onTakeLiveExam(
    TakeLiveExamRequested event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(liveExamStatus: LoadStatus.loading, clearError: true));
    final result = await repository.takeLiveExam(event.examId);
    result.fold(
      (failure) => emit(state.copyWith(
        liveExamStatus: LoadStatus.error,
        errorMessage: failure.message,
      )),
      (exam) => emit(state.copyWith(
        liveExamStatus: LoadStatus.loaded,
        activeLiveExam: exam,
      )),
    );
  }

  Future<void> _onSubmitLiveExam(
    SubmitLiveExamRequested event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, actionSucceeded: false));
    final result = await repository.submitLiveExam(event.examId, event.answers);
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(isSubmitting: false, actionSucceeded: true)),
    );
  }

  Future<void> _onLoadLiveExamSubmissions(
    LoadLiveExamSubmissions event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(liveExamStatus: LoadStatus.loading, clearError: true));
    final result = await repository.getLiveExamSubmissions(event.examId);
    result.fold(
      (failure) => emit(state.copyWith(
        liveExamStatus: LoadStatus.error,
        errorMessage: failure.message,
      )),
      (submissions) => emit(state.copyWith(
        liveExamStatus: LoadStatus.loaded,
        liveExamSubmissions: submissions,
      )),
    );
  }

  Future<void> _onGradeLiveExam(
    GradeLiveExamRequested event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, actionSucceeded: false));
    final result = await repository.gradeLiveExamSubmission(
      event.submissionId,
      event.marks,
      event.feedback,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(isSubmitting: false, actionSucceeded: true)),
    );
  }

  // ── AI writing ─────────────────────────────────────────────────────────

  Future<void> _onLoadAiWritingTasks(
    LoadAiWritingTasks event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(aiWritingStatus: LoadStatus.loading, clearError: true));
    final result = await repository.getAiWritingByCourse(event.courseId);
    result.fold(
      (failure) => emit(state.copyWith(
        aiWritingStatus: LoadStatus.error,
        errorMessage: failure.message,
      )),
      (tasks) => emit(state.copyWith(
        aiWritingStatus: LoadStatus.loaded,
        aiWritingTasks: tasks,
      )),
    );
  }

  Future<void> _onLoadAiWritingTask(
    LoadAiWritingTask event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(aiWritingStatus: LoadStatus.loading, clearError: true));

    final taskResult = await repository.getAiWritingTask(event.taskId);
    final submissionsResult = await repository.getAiWritingSubmissions(event.taskId);

    String? error;
    final task = taskResult.fold(
      (failure) {
        error = failure.message;
        return state.activeAiTask;
      },
      (value) => value,
    );
    final submissions = submissionsResult.fold(
      (failure) {
        error ??= failure.message;
        return state.aiSubmissions;
      },
      (value) => value,
    );

    emit(state.copyWith(
      aiWritingStatus: error != null ? LoadStatus.error : LoadStatus.loaded,
      activeAiTask: task,
      aiSubmissions: submissions,
      errorMessage: error,
    ));
  }

  /// Uploads a handwritten answer photo for AI marking.
  ///
  /// Manual §4.4: *"Multiple attempts allowed — the last one counts."* so the
  /// task is reloaded afterwards to surface the newest attempt.
  Future<void> _onSubmitAiWriting(
    SubmitAiWritingRequested event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, actionSucceeded: false));
    final result = await repository.submitAiWriting(event.taskId, event.photo);
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(isSubmitting: false, actionSucceeded: true));
        add(LoadAiWritingTask(event.taskId));
      },
    );
  }

  // ── Practice ───────────────────────────────────────────────────────────

  Future<void> _onLoadPracticeFiles(
    LoadPracticeFiles event,
    Emitter<LearningState> emit,
  ) async {
    emit(state.copyWith(hubStatus: LoadStatus.loading, clearError: true));
    final result = await repository.getPracticeByCourse(event.courseId);
    result.fold(
      (failure) => emit(state.copyWith(
        hubStatus: LoadStatus.error,
        errorMessage: failure.message,
      )),
      (files) => emit(state.copyWith(
        hubStatus: LoadStatus.loaded,
        practiceFiles: files,
      )),
    );
  }
}