import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Domain/Entities/quiz_entity.dart';
import '../../../Domain/Repositories/course_repository.dart';
import 'course_event.dart';
import 'course_state.dart';

/// Central BLoC for the course catalogue, enrolled courses, teacher course
/// management, quizzes and live classes.
///
/// **Design note — one BLoC, many sections.** The course hub needs courses,
/// lessons, live classes, recordings and quiz state at once. Rather than five
/// BLoCs that would race each other, this BLoC keeps a [CourseStatus] per
/// section in a single state object. Each section therefore shows its own
/// spinner or error without blanking the rest of the screen.
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository courseRepository;

  CourseBloc({required this.courseRepository}) : super(const CourseState()) {
    // Catalogue & enrollment
    on<LoadAllCourses>(_onLoadAllCourses);
    on<LoadTeacherCourses>(_onLoadTeacherCourses);
    on<LoadMyEnrollments>(_onLoadMyEnrollments);
    on<LoadCourseDetails>(_onLoadCourseDetails);
    on<EnrollInCourseEvent>(_onEnrollInCourse);

    // Wishlist
    on<ToggleWishlistEvent>(_onToggleWishlist);
    on<CheckWishlistStatus>(_onCheckWishlist);
    on<LoadMyWishlist>(_onLoadMyWishlist);

    // Teacher authoring
    on<CreateCourseRequested>(_onCreateCourse);
    on<AddLessonRequested>(_onAddLesson);
    on<AddQuizQuestionRequested>(_onAddQuizQuestion);

    // Quiz
    on<LoadQuizQuestionsRequested>(_onLoadQuizQuestions);
    on<SubmitQuizRequested>(_onSubmitQuiz);
    on<LoadQuizLeaderboard>(_onLoadQuizLeaderboard);

    // Live classes & recordings
    on<LoadLiveClassesRequested>(_onLoadLiveClasses);
    on<LoadRecordingsRequested>(_onLoadRecordings);
    on<UploadRecordingRequested>(_onUploadRecording);

    // Progress
    on<SaveVideoProgressRequested>(_onSaveVideoProgress);

    // Feedback
    on<ClearCourseFeedback>(_onClearFeedback);
  }

  // ── Catalogue ──────────────────────────────────────────────────────────

  Future<void> _onLoadAllCourses(
    LoadAllCourses event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(allCoursesStatus: CourseStatus.loading, clearError: true));
    final result = await courseRepository.getAllCourses();
    result.fold(
      (failure) => emit(state.copyWith(
        allCoursesStatus: CourseStatus.error,
        errorMessage: failure.message,
      )),
      (courses) => emit(state.copyWith(
        allCoursesStatus: CourseStatus.loaded,
        allCourses: courses,
      )),
    );
  }

  Future<void> _onLoadTeacherCourses(
    LoadTeacherCourses event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(teacherStatus: CourseStatus.loading, clearError: true));
    final result = await courseRepository.getTeacherCourses();
    result.fold(
      (failure) => emit(state.copyWith(
        teacherStatus: CourseStatus.error,
        errorMessage: failure.message,
      )),
      (courses) => emit(state.copyWith(
        teacherStatus: CourseStatus.loaded,
        teacherCourses: courses,
      )),
    );
  }

  Future<void> _onLoadMyEnrollments(
    LoadMyEnrollments event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(enrolledStatus: CourseStatus.loading, clearError: true));
    final result = await courseRepository.getMyEnrollments();
    result.fold(
      (failure) => emit(state.copyWith(
        enrolledStatus: CourseStatus.error,
        errorMessage: failure.message,
      )),
      (courses) => emit(state.copyWith(
        enrolledStatus: CourseStatus.loaded,
        enrolledCourses: courses,
      )),
    );
  }

  /// Loads a course plus its lesson list for the details / hub screen.
  ///
  /// The two requests run sequentially because the lessons call is scoped to the
  /// course and there is no benefit to racing them on a slow connection.
  Future<void> _onLoadCourseDetails(
    LoadCourseDetails event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(detailsStatus: CourseStatus.loading, clearError: true));

    final courseResult = await courseRepository.getCourseById(event.courseId);
    final lessonsResult = await courseRepository.getLessonsByCourse(event.courseId);

    String? error;
    final course = courseResult.fold(
      (failure) {
        error = failure.message;
        return null;
      },
      (value) => value,
    );

    final lessons = lessonsResult.fold(
      (failure) {
        error ??= failure.message;
        return state.lessons;
      },
      (value) => value,
    );

    emit(state.copyWith(
      detailsStatus: error != null ? CourseStatus.error : CourseStatus.loaded,
      selectedCourse: course,
      lessons: lessons,
      errorMessage: error,
    ));
  }

  Future<void> _onEnrollInCourse(
    EnrollInCourseEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, actionSucceeded: false));
    final result = await courseRepository.enrollInCourse(event.courseId);
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) {
        emit(state.copyWith(isSubmitting: false, actionSucceeded: true));
        // Refresh both views so the course appears in My Courses immediately.
        add(LoadCourseDetails(event.courseId));
        add(LoadMyEnrollments());
      },
    );
  }

  // ── Wishlist ───────────────────────────────────────────────────────────

  Future<void> _onToggleWishlist(
    ToggleWishlistEvent event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(clearError: true, actionSucceeded: false));
    final result = await courseRepository.toggleWishlist(event.courseId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        emit(state.copyWith(actionSucceeded: true));
        add(LoadAllCourses());
        add(const LoadMyWishlist());
      },
    );
  }

  /// Reads the wishlist flag for a single course.
  ///
  /// Previously this event was declared but never handled, so the heart icon
  /// could never reflect the saved state.
  Future<void> _onCheckWishlist(
    CheckWishlistStatus event,
    Emitter<CourseState> emit,
  ) async {
    final result = await courseRepository.checkWishlist(event.courseId);
    result.fold(
      (_) {}, // A failed status check is non-fatal — leave the icon as-is.
      (isWishlisted) {
        final updated = state.allCourses.map((course) {
          return course.id == event.courseId
              ? course.copyWithWishlist(isWishlisted)
              : course;
        }).toList();
        emit(state.copyWith(allCourses: updated));
      },
    );
  }

  Future<void> _onLoadMyWishlist(
    LoadMyWishlist event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(wishlistStatus: CourseStatus.loading, clearError: true));
    final result = await courseRepository.getMyWishlist();
    result.fold(
      (failure) => emit(state.copyWith(
        wishlistStatus: CourseStatus.error,
        errorMessage: failure.message,
      )),
      (courses) => emit(state.copyWith(
        wishlistStatus: CourseStatus.loaded,
        wishlist: courses,
      )),
    );
  }

  // ── Teacher authoring ──────────────────────────────────────────────────

  Future<void> _onCreateCourse(
    CreateCourseRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(teacherStatus: CourseStatus.loading, clearError: true, actionSucceeded: false));
    final result = await courseRepository.createCourse(event.data);

    await result.fold(
      (failure) async => emit(state.copyWith(
        teacherStatus: CourseStatus.error,
        errorMessage: failure.message,
      )),
      (courseId) async {
        if (event.thumbnail != null) {
          // A failed thumbnail upload must not be reported as a successful
          // course creation, so its result is checked explicitly.
          final uploadResult =
              await courseRepository.uploadThumbnail(courseId, event.thumbnail!);
          final uploadFailed = uploadResult.isLeft();
          if (uploadFailed) {
            emit(state.copyWith(
              teacherStatus: CourseStatus.loaded,
              actionSucceeded: true,
              errorMessage:
                  'Course created, but the thumbnail could not be uploaded.',
            ));
            add(LoadTeacherCourses());
            return;
          }
        }
        emit(state.copyWith(teacherStatus: CourseStatus.loaded, actionSucceeded: true));
        add(LoadTeacherCourses());
      },
    );
  }

  Future<void> _onAddLesson(
    AddLessonRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(detailsStatus: CourseStatus.loading, clearError: true, actionSucceeded: false));
    final result = await courseRepository.createLesson(event.data);

    await result.fold(
      (failure) async => emit(state.copyWith(
        detailsStatus: CourseStatus.error,
        errorMessage: failure.message,
      )),
      (lessonId) async {
        if (event.video != null) {
          await courseRepository.uploadLessonVideo(lessonId, event.video!);
        }
        emit(state.copyWith(detailsStatus: CourseStatus.loaded, actionSucceeded: true));
        final courseId = event.data['courseId'];
        if (courseId != null) {
          add(LoadCourseDetails(courseId.toString()));
        }
      },
    );
  }

  Future<void> _onAddQuizQuestion(
    AddQuizQuestionRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(quizStatus: CourseStatus.loading, clearError: true, actionSucceeded: false));
    final result = await courseRepository.addQuizQuestion(event.lessonId, event.quizData);
    result.fold(
      (failure) => emit(state.copyWith(
        quizStatus: CourseStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(quizStatus: CourseStatus.loaded, actionSucceeded: true)),
    );
  }

  // ── Quiz ───────────────────────────────────────────────────────────────

  /// Loads a lesson's quiz questions **and** whether the student already sat it.
  ///
  /// This previously had empty `fold` branches, so `hasAttemptedQuiz` was
  /// fetched and then thrown away — the UI could never show "already attempted".
  Future<void> _onLoadQuizQuestions(
    LoadQuizQuestionsRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(quizStatus: CourseStatus.loading, clearError: true));

    final questionsResult = await courseRepository.getQuizQuestions(event.lessonId);
    final attemptedResult = await courseRepository.hasAttemptedQuiz(event.lessonId);

    String? error;
    final questions = questionsResult.fold(
      (failure) {
        error = failure.message;
        return <QuestionEntity>[];
      },
      (value) => value,
    );
    final attempted = attemptedResult.fold(
      (_) => state.hasAttemptedQuiz,
      (value) => value,
    );

    emit(state.copyWith(
      quizStatus: error != null ? CourseStatus.error : CourseStatus.loaded,
      activeQuiz: QuizEntity(
        lessonId: event.lessonId,
        questions: questions,
        hasAttempted: attempted,
      ),
      hasAttemptedQuiz: attempted,
      errorMessage: error,
    ));
  }

  /// Submits quiz answers and **keeps the returned score**.
  ///
  /// Previously the response map was discarded, so the results page had no data.
  Future<void> _onSubmitQuiz(
    SubmitQuizRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(quizStatus: CourseStatus.loading, clearError: true, actionSucceeded: false));
    final result = await courseRepository.submitQuiz(event.lessonId, event.answers);
    result.fold(
      (failure) => emit(state.copyWith(
        quizStatus: CourseStatus.error,
        errorMessage: failure.message,
      )),
      (data) {
        // Accept several plausible key spellings because the endpoint's
        // response schema is untyped in the live spec.
        final score = _asInt(data['score'] ?? data['marks'] ?? data['obtainedMarks']);
        final total = _asInt(
          data['totalQuestions'] ?? data['total'] ?? data['totalMarks'],
        );
        final correct = _asInt(
          data['correctAnswers'] ?? data['correct'] ?? data['correctCount'],
        );

        emit(state.copyWith(
          quizStatus: CourseStatus.loaded,
          actionSucceeded: true,
          hasAttemptedQuiz: true,
          lastQuizScore: score,
          lastQuizTotal: total,
          lastQuizCorrect: correct,
        ));
      },
    );
  }

  Future<void> _onLoadQuizLeaderboard(
    LoadQuizLeaderboard event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(quizStatus: CourseStatus.loading, clearError: true));
    final result = await courseRepository.getQuizLeaderboard();
    result.fold(
      (failure) => emit(state.copyWith(
        quizStatus: CourseStatus.error,
        errorMessage: failure.message,
      )),
      (rows) => emit(state.copyWith(
        quizStatus: CourseStatus.loaded,
        leaderboard: rows,
      )),
    );
  }

  // ── Live classes & recordings ──────────────────────────────────────────

  Future<void> _onLoadLiveClasses(
    LoadLiveClassesRequested event,
    Emitter<CourseState> emit,
  ) async {
    final result = await courseRepository.getLiveClassesByCourse(event.courseId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (classes) => emit(state.copyWith(liveClasses: classes)),
    );
  }

  Future<void> _onLoadRecordings(
    LoadRecordingsRequested event,
    Emitter<CourseState> emit,
  ) async {
    final result = await courseRepository.getRecordingsByCourse(event.courseId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (recordings) => emit(state.copyWith(recordings: recordings)),
    );
  }

  /// Uploads a live-class recording (Rule 11).
  ///
  /// The upload can run for a long time and has no size limit, so the UI keeps
  /// a progress indicator visible until this completes.
  Future<void> _onUploadRecording(
    UploadRecordingRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, actionSucceeded: false));
    final result =
        await courseRepository.uploadRecording(event.liveClassId, event.file);
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(isSubmitting: false, actionSucceeded: true)),
    );
  }

  // ── Video progress ─────────────────────────────────────────────────────

  /// Persists playback position.
  ///
  /// A failure here is silent by design: it fires on a timer during playback
  /// and must never interrupt the student with an error dialog.
  Future<void> _onSaveVideoProgress(
    SaveVideoProgressRequested event,
    Emitter<CourseState> emit,
  ) async {
    // Deliberately ignores the result: this fires on a timer during playback
    // and must never interrupt the student with an error dialog.
    await courseRepository.saveVideoProgress(event.lessonId, event.progressData);
  }

  // ── Feedback ───────────────────────────────────────────────────────────

  Future<void> _onClearFeedback(
    ClearCourseFeedback event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(actionSucceeded: false, clearError: true));
  }

  /// Coerces a dynamic JSON value to an int, returning null when absent.
  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}