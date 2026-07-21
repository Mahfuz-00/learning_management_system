import 'package:equatable/equatable.dart';
import '../../../Domain/Entities/course_entity.dart';
import '../../../Domain/Entities/lesson_entity.dart';
import '../../../Domain/Entities/quiz_entity.dart';
import '../../../Domain/Entities/live_class_entity.dart';

enum CourseStatus { initial, loading, loaded, error }

class CourseState extends Equatable {
  final CourseStatus allCoursesStatus;
  final List<CourseEntity> allCourses;
  
  final CourseStatus enrolledStatus;
  final List<CourseEntity> enrolledCourses;
  
  final CourseStatus teacherStatus;
  final List<CourseEntity> teacherCourses;
  
  final CourseStatus detailsStatus;
  final CourseEntity? selectedCourse;
  final List<LessonEntity> lessons;
  final List<LiveClassEntity> liveClasses;
  
  final QuizEntity? activeQuiz;
  final CourseStatus quizStatus;
  
  final String? errorMessage;

  const CourseState({
    this.allCoursesStatus = CourseStatus.initial,
    this.allCourses = const [],
    this.enrolledStatus = CourseStatus.initial,
    this.enrolledCourses = const [],
    this.teacherStatus = CourseStatus.initial,
    this.teacherCourses = const [],
    this.detailsStatus = CourseStatus.initial,
    this.selectedCourse,
    this.lessons = const [],
    this.liveClasses = const [],
    this.activeQuiz,
    this.quizStatus = CourseStatus.initial,
    this.errorMessage,
  });

  CourseState copyWith({
    CourseStatus? allCoursesStatus,
    List<CourseEntity>? allCourses,
    CourseStatus? enrolledStatus,
    List<CourseEntity>? enrolledCourses,
    CourseStatus? teacherStatus,
    List<CourseEntity>? teacherCourses,
    CourseStatus? detailsStatus,
    CourseEntity? selectedCourse,
    List<LessonEntity>? lessons,
    List<LiveClassEntity>? liveClasses,
    QuizEntity? activeQuiz,
    CourseStatus? quizStatus,
    String? errorMessage,
  }) {
    return CourseState(
      allCoursesStatus: allCoursesStatus ?? this.allCoursesStatus,
      allCourses: allCourses ?? this.allCourses,
      enrolledStatus: enrolledStatus ?? this.enrolledStatus,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      teacherStatus: teacherStatus ?? this.teacherStatus,
      teacherCourses: teacherCourses ?? this.teacherCourses,
      detailsStatus: detailsStatus ?? this.detailsStatus,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      lessons: lessons ?? this.lessons,
      liveClasses: liveClasses ?? this.liveClasses,
      activeQuiz: activeQuiz ?? this.activeQuiz,
      quizStatus: quizStatus ?? this.quizStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        allCoursesStatus,
        allCourses,
        enrolledStatus,
        enrolledCourses,
        teacherStatus,
        teacherCourses,
        detailsStatus,
        selectedCourse,
        lessons,
        liveClasses,
        activeQuiz,
        quizStatus,
        errorMessage,
      ];
}
