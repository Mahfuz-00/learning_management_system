import 'package:equatable/equatable.dart';
import '../../../Domain/Entities/course_entity.dart';
import '../../../Domain/Entities/lesson_entity.dart';
import '../../../Domain/Entities/quiz_entity.dart';

abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CoursesLoaded extends CourseState {
  final List<CourseEntity> courses;
  const CoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class CourseDetailLoaded extends CourseState {
  final CourseEntity course;
  final List<LessonEntity> lessons;
  final bool isEnrolled;
  const CourseDetailLoaded(this.course, this.lessons, this.isEnrolled);

  @override
  List<Object?> get props => [course, lessons, isEnrolled];
}

class QuizLoaded extends CourseState {
  final QuizEntity quiz;
  const QuizLoaded(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class QuizSubmitted extends CourseState {}

class EnrollmentSuccess extends CourseState {}

class CourseError extends CourseState {
  final String message;
  const CourseError(this.message);

  @override
  List<Object?> get props => [message];
}
