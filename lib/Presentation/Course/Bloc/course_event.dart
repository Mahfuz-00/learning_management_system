import 'package:equatable/equatable.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object> get props => [];
}

class GetAllCoursesRequested extends CourseEvent {}

class GetMyCoursesRequested extends CourseEvent {}

class GetCourseDetailsRequested extends CourseEvent {
  final String courseId;
  const GetCourseDetailsRequested(this.courseId);

  @override
  List<Object> get props => [courseId];
}

class EnrollRequested extends CourseEvent {
  final String courseId;
  const EnrollRequested(this.courseId);

  @override
  List<Object> get props => [courseId];
}

class SaveVideoProgressRequested extends CourseEvent {
  final String lessonId;
  final double progress;

  const SaveVideoProgressRequested({required this.lessonId, required this.progress});

  @override
  List<Object> get props => [lessonId, progress];
}

class GetQuizRequested extends CourseEvent {
  final String lessonId;
  const GetQuizRequested(this.lessonId);

  @override
  List<Object> get props => [lessonId];
}

class SubmitQuizRequested extends CourseEvent {
  final String quizId;
  final Map<String, dynamic> answers;

  const SubmitQuizRequested({required this.quizId, required this.answers});

  @override
  List<Object> get props => [quizId, answers];
}
