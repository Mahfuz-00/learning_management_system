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

/// Loads the global quiz leaderboard (Manual §4.4).
class LoadQuizLeaderboard extends CourseEvent {
  const LoadQuizLeaderboard();
}

// Live Class Events
class LoadLiveClassesRequested extends CourseEvent {
  final String courseId;
  const LoadLiveClassesRequested(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

/// Loads the **past** live classes the teacher uploaded (the Recordings card).
///
/// Manual §4.3: *"Past live classes the teacher uploaded. Plays in the site's
/// own video player."*
class LoadRecordingsRequested extends CourseEvent {
  final String courseId;
  const LoadRecordingsRequested(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

/// Loads the wishlist for the signed-in student.
class LoadMyWishlist extends CourseEvent {
  const LoadMyWishlist();
}

/// Uploads a live-class recording (Rule 11 — teacher only).
///
/// *"There is no automatic recording. The teacher must press record inside the
/// live class, keep the tab open until the end, and then upload the file."*
class UploadRecordingRequested extends CourseEvent {
  final String liveClassId;
  final File file;
  const UploadRecordingRequested({required this.liveClassId, required this.file});

  @override
  List<Object?> get props => [liveClassId, file];
}

/// Clears the one-shot feedback flags after the UI has shown its message.
class ClearCourseFeedback extends CourseEvent {
  const ClearCourseFeedback();
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
