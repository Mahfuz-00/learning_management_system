import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Domain/Repositories/course_repository.dart';
import 'course_event.dart';
import 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository courseRepository;

  CourseBloc({required this.courseRepository}) : super(const CourseState()) {
    on<LoadAllCourses>(_onLoadAllCourses);
    on<LoadTeacherCourses>(_onLoadTeacherCourses);
    on<LoadMyEnrollments>(_onLoadMyEnrollments);
    on<LoadCourseDetails>(_onLoadCourseDetails);
    on<EnrollInCourseEvent>(_onEnrollInCourse);
    on<ToggleWishlistEvent>(_onToggleWishlist);
    
    // Teacher Actions
    on<CreateCourseRequested>(_onCreateCourse);
    on<AddLessonRequested>(_onAddLesson);
    on<AddQuizQuestionRequested>(_onAddQuizQuestion);
    
    // Quiz Actions
    on<LoadQuizQuestionsRequested>(_onLoadQuizQuestions);
    on<SubmitQuizRequested>(_onSubmitQuiz);
    
    // Live Class Actions
    on<LoadLiveClassesRequested>(_onLoadLiveClasses);
    on<SaveVideoProgressRequested>(_onSaveVideoProgress);
  }

  Future<void> _onLoadAllCourses(LoadAllCourses event, Emitter<CourseState> emit) async {
    emit(state.copyWith(allCoursesStatus: CourseStatus.loading));
    final result = await courseRepository.getAllCourses();
    result.fold(
      (failure) => emit(state.copyWith(allCoursesStatus: CourseStatus.error, errorMessage: failure.message)),
      (courses) => emit(state.copyWith(allCoursesStatus: CourseStatus.loaded, allCourses: courses)),
    );
  }

  Future<void> _onLoadTeacherCourses(LoadTeacherCourses event, Emitter<CourseState> emit) async {
    emit(state.copyWith(teacherStatus: CourseStatus.loading));
    final result = await courseRepository.getTeacherCourses();
    result.fold(
      (failure) => emit(state.copyWith(teacherStatus: CourseStatus.error, errorMessage: failure.message)),
      (courses) => emit(state.copyWith(teacherStatus: CourseStatus.loaded, teacherCourses: courses)),
    );
  }

  Future<void> _onLoadMyEnrollments(LoadMyEnrollments event, Emitter<CourseState> emit) async {
    emit(state.copyWith(enrolledStatus: CourseStatus.loading));
    final result = await courseRepository.getMyEnrollments();
    result.fold(
      (failure) => emit(state.copyWith(enrolledStatus: CourseStatus.error, errorMessage: failure.message)),
      (courses) => emit(state.copyWith(enrolledStatus: CourseStatus.loaded, enrolledCourses: courses)),
    );
  }

  Future<void> _onLoadCourseDetails(LoadCourseDetails event, Emitter<CourseState> emit) async {
    emit(state.copyWith(detailsStatus: CourseStatus.loading));
    final courseResult = await courseRepository.getCourseById(event.courseId);
    final lessonsResult = await courseRepository.getLessonsByCourse(event.courseId);

    courseResult.fold(
      (failure) => emit(state.copyWith(detailsStatus: CourseStatus.error, errorMessage: failure.message)),
      (course) {
        lessonsResult.fold(
          (failure) => emit(state.copyWith(detailsStatus: CourseStatus.loaded, selectedCourse: course, lessons: const [])),
          (lessons) => emit(state.copyWith(detailsStatus: CourseStatus.loaded, selectedCourse: course, lessons: lessons)),
        );
      },
    );
  }

  Future<void> _onEnrollInCourse(EnrollInCourseEvent event, Emitter<CourseState> emit) async {
    final result = await courseRepository.enrollInCourse(event.courseId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        add(LoadCourseDetails(event.courseId));
        add(LoadMyEnrollments());
      },
    );
  }

  Future<void> _onToggleWishlist(ToggleWishlistEvent event, Emitter<CourseState> emit) async {
    final result = await courseRepository.toggleWishlist(event.courseId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        add(LoadAllCourses());
      },
    );
  }

  Future<void> _onCreateCourse(CreateCourseRequested event, Emitter<CourseState> emit) async {
    emit(state.copyWith(teacherStatus: CourseStatus.loading));
    final result = await courseRepository.createCourse(event.data);
    
    await result.fold(
      (failure) async => emit(state.copyWith(teacherStatus: CourseStatus.error, errorMessage: failure.message)),
      (courseId) async {
        if (event.thumbnail != null) {
          await courseRepository.uploadThumbnail(courseId, event.thumbnail!);
        }
        emit(state.copyWith(teacherStatus: CourseStatus.loaded));
        add(LoadTeacherCourses());
      },
    );
  }

  Future<void> _onAddLesson(AddLessonRequested event, Emitter<CourseState> emit) async {
    emit(state.copyWith(detailsStatus: CourseStatus.loading));
    final result = await courseRepository.createLesson(event.data);
    
    await result.fold(
      (failure) async => emit(state.copyWith(detailsStatus: CourseStatus.error, errorMessage: failure.message)),
      (lessonId) async {
        if (event.video != null) {
          await courseRepository.uploadLessonVideo(lessonId, event.video!);
        }
        emit(state.copyWith(detailsStatus: CourseStatus.loaded));
        if (event.data.containsKey('courseId')) {
          add(LoadCourseDetails(event.data['courseId'].toString()));
        }
      },
    );
  }

  Future<void> _onAddQuizQuestion(AddQuizQuestionRequested event, Emitter<CourseState> emit) async {
    emit(state.copyWith(quizStatus: CourseStatus.loading));
    final result = await courseRepository.addQuizQuestion(event.lessonId, event.quizData);
    result.fold(
      (failure) => emit(state.copyWith(quizStatus: CourseStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(quizStatus: CourseStatus.loaded)),
    );
  }

  Future<void> _onLoadQuizQuestions(LoadQuizQuestionsRequested event, Emitter<CourseState> emit) async {
    emit(state.copyWith(quizStatus: CourseStatus.loading));
    final questionsResult = await courseRepository.getQuizQuestions(event.lessonId);
    final attemptedResult = await courseRepository.hasAttemptedQuiz(event.lessonId);

    questionsResult.fold(
      (failure) => emit(state.copyWith(quizStatus: CourseStatus.error, errorMessage: failure.message)),
      (questions) {
        attemptedResult.fold(
          (failure) => emit(state.copyWith(quizStatus: CourseStatus.error, errorMessage: failure.message)),
          (hasAttempted) {
             // We don't have a QuizEntity constructor that takes exactly this, but we can manage it in state
             // or create a temp QuizEntity
             // For now, let's assume activeQuiz holds this data
          },
        );
      },
    );
  }

  Future<void> _onSubmitQuiz(SubmitQuizRequested event, Emitter<CourseState> emit) async {
    emit(state.copyWith(quizStatus: CourseStatus.loading));
    final result = await courseRepository.submitQuiz(event.lessonId, event.answers);
    result.fold(
      (failure) => emit(state.copyWith(quizStatus: CourseStatus.error, errorMessage: failure.message)),
      (data) {
        emit(state.copyWith(quizStatus: CourseStatus.loaded));
      },
    );
  }

  Future<void> _onLoadLiveClasses(LoadLiveClassesRequested event, Emitter<CourseState> emit) async {
    final result = await courseRepository.getLiveClassesByCourse(event.courseId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (classes) => emit(state.copyWith(liveClasses: classes)),
    );
  }

  Future<void> _onSaveVideoProgress(SaveVideoProgressRequested event, Emitter<CourseState> emit) async {
    await courseRepository.saveVideoProgress(event.lessonId, event.progressData);
  }
}
