import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Domain/UseCases/Course/get_all_courses_usecase.dart';
import '../../../Domain/UseCases/Course/get_my_courses_usecase.dart';
import '../../../Domain/Repositories/course_repository.dart';
import 'course_event.dart';
import 'course_state.dart';
import 'dart:developer';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final GetAllCoursesUseCase getAllCoursesUseCase;
  final GetMyCoursesUseCase getMyCoursesUseCase;
  final CourseRepository courseRepository;

  CourseBloc({
    required this.getAllCoursesUseCase,
    required this.getMyCoursesUseCase,
    required this.courseRepository,
  }) : super(CourseInitial()) {
    on<GetAllCoursesRequested>(_onGetAllCoursesRequested);
    on<GetMyCoursesRequested>(_onGetMyCoursesRequested);
    on<GetCourseDetailsRequested>(_onGetCourseDetailsRequested);
    on<EnrollRequested>(_onEnrollRequested);
    on<SaveVideoProgressRequested>(_onSaveVideoProgressRequested);
    on<GetQuizRequested>(_onGetQuizRequested);
    on<SubmitQuizRequested>(_onSubmitQuizRequested);
  }

  Future<void> _onGetAllCoursesRequested(
      GetAllCoursesRequested event, Emitter<CourseState> emit) async {
    log('Bloc: GetAllCoursesRequested');
    emit(CourseLoading());
    final result = await getAllCoursesUseCase();
    result.fold(
      (failure) {
        log('Bloc Error: GetAllCourses failed: ${failure.message}');
        emit(CourseError(failure.message));
      },
      (courses) {
        log('Bloc Success: CoursesLoaded');
        emit(CoursesLoaded(courses));
      },
    );
  }

  Future<void> _onGetMyCoursesRequested(
      GetMyCoursesRequested event, Emitter<CourseState> emit) async {
    log('Bloc: GetMyCoursesRequested');
    emit(CourseLoading());
    final result = await getMyCoursesUseCase();
    result.fold(
      (failure) {
        log('Bloc Error: GetMyCourses failed: ${failure.message}');
        emit(CourseError(failure.message));
      },
      (courses) {
        log('Bloc Success: My CoursesLoaded');
        emit(CoursesLoaded(courses));
      },
    );
  }

  Future<void> _onGetCourseDetailsRequested(
      GetCourseDetailsRequested event, Emitter<CourseState> emit) async {
    log('Bloc: GetCourseDetailsRequested for ${event.courseId}');
    emit(CourseLoading());
    
    final courseResult = await courseRepository.getCourseById(event.courseId);
    final lessonsResult = await courseRepository.getLessonsByCourse(event.courseId);
    final statusResult = await courseRepository.checkEnrollmentStatus(event.courseId);

    courseResult.fold(
      (failure) {
        log('Bloc Error: GetCourseById failed: ${failure.message}');
        emit(CourseError(failure.message));
      },
      (course) {
        bool isEnrolled = false;
        statusResult.fold((f) {
           log('Bloc Warning: checkEnrollmentStatus failed: ${f.message}');
           isEnrolled = false;
        }, (status) => isEnrolled = status);
        
        lessonsResult.fold(
          (failure) {
            log('Bloc Warning: GetLessonsByCourse failed: ${failure.message}');
            emit(CourseDetailLoaded(course, const [], isEnrolled));
          },
          (lessons) {
            log('Bloc Success: CourseDetailLoaded with ${lessons.length} lessons');
            emit(CourseDetailLoaded(course, lessons, isEnrolled));
          },
        );
      },
    );
  }

  Future<void> _onEnrollRequested(
      EnrollRequested event, Emitter<CourseState> emit) async {
    log('Bloc: EnrollRequested for ${event.courseId}');
    emit(CourseLoading());
    final result = await courseRepository.enrollInCourse(event.courseId);
    result.fold(
      (failure) {
        log('Bloc Error: Enrollment failed: ${failure.message}');
        emit(CourseError(failure.message));
      },
      (_) {
        log('Bloc Success: EnrollmentSuccess');
        emit(EnrollmentSuccess());
      },
    );
  }

  Future<void> _onSaveVideoProgressRequested(
      SaveVideoProgressRequested event, Emitter<CourseState> emit) async {
    log('Bloc: SaveVideoProgressRequested for lesson ${event.lessonId} with progress ${event.progress}');
    await courseRepository.saveVideoProgress(event.lessonId, event.progress);
  }

  Future<void> _onGetQuizRequested(
      GetQuizRequested event, Emitter<CourseState> emit) async {
    log('Bloc: GetQuizRequested for lesson ${event.lessonId}');
    emit(CourseLoading());
    final result = await courseRepository.getQuizByLesson(event.lessonId);
    result.fold(
      (failure) {
        log('Bloc Error: GetQuizByLesson failed: ${failure.message}');
        emit(CourseError(failure.message));
      },
      (quiz) {
        log('Bloc Success: QuizLoaded');
        emit(QuizLoaded(quiz));
      },
    );
  }

  Future<void> _onSubmitQuizRequested(
      SubmitQuizRequested event, Emitter<CourseState> emit) async {
    log('Bloc: SubmitQuizRequested for quiz ${event.quizId}');
    emit(CourseLoading());
    final result = await courseRepository.submitQuizAttempt(event.quizId, event.answers);
    result.fold(
      (failure) {
        log('Bloc Error: SubmitQuizAttempt failed: ${failure.message}');
        emit(CourseError(failure.message));
      },
      (_) {
        log('Bloc Success: QuizSubmitted');
        emit(QuizSubmitted());
      },
    );
  }
}
