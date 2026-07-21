import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllCourses extends CourseEvent {}

class LoadTeacherCourses extends CourseEvent {}

class LoadMyEnrollments extends CourseEvent {}

class LoadCourseDetails extends CourseEvent {
  final String courseId;
  const LoadCourseDetails(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class EnrollInCourseEvent extends CourseEvent {
  final String courseId;
  const EnrollInCourseEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class ToggleWishlistEvent extends CourseEvent {
  final String courseId;
  const ToggleWishlistEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class CheckWishlistStatus extends CourseEvent {
  final String courseId;
  const CheckWishlistStatus(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

// Teacher Specific Events
class CreateCourseRequested extends CourseEvent {
  final Map<String, dynamic> data;
  final File? thumbnail;

  const CreateCourseRequested({required this.data, this.thumbnail});

  @override
  List<Object?> get props => [data, thumbnail];
}

class AddLessonRequested extends CourseEvent {
  final Map<String, dynamic> data;
  final File? video;

  const AddLessonRequested({required this.data, this.video});

  @override
  List<Object?> get props => [data, video];
}

class AddQuizQuestionRequested extends CourseEvent {
  final String lessonId;
  final Map<String, dynamic> quizData;

  const AddQuizQuestionRequested({required this.lessonId, required this.quizData});

  @override
  List<Object?> get props => [lessonId, quizData];
}

// Quiz Events
class LoadQuizQuestionsRequested extends CourseEvent {
  final String lessonId;
  const LoadQuizQuestionsRequested(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class SubmitQuizRequested extends CourseEvent {
  final String lessonId;
  final Map<String, dynamic> answers;

  const SubmitQuizRequested({required this.lessonId, required this.answers});

  @override
  List<Object?> get props => [lessonId, answers];
}

// Live Class Events
class LoadLiveClassesRequested extends CourseEvent {
  final String courseId;
  const LoadLiveClassesRequested(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class JoinLiveClassRequested extends CourseEvent {
  final String liveClassId;
  const JoinLiveClassRequested(this.liveClassId);

  @override
  List<Object?> get props => [liveClassId];
}

class SaveVideoProgressRequested extends CourseEvent {
  final String lessonId;
  final Map<String, dynamic> progressData;

  const SaveVideoProgressRequested({required this.lessonId, required this.progressData});

  @override
  List<Object?> get props => [lessonId, progressData];
}
