import 'package:equatable/equatable.dart';

abstract class LessonEvent extends Equatable {
  const LessonEvent();

  @override
  List<Object?> get props => [];
}

class DownloadVideoRequested extends LessonEvent {
  final String videoUrl;
  final String lessonId;

  const DownloadVideoRequested({required this.videoUrl, required this.lessonId});

  @override
  List<Object?> get props => [videoUrl, lessonId];
}

class DeleteDownloadedVideoRequested extends LessonEvent {
  final String lessonId;

  const DeleteDownloadedVideoRequested(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class CheckVideoDownloadStatus extends LessonEvent {
  final String lessonId;

  const CheckVideoDownloadStatus(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class MarkLessonAsCompletedRequested extends LessonEvent {
  final String lessonId;
  final String courseId;

  const MarkLessonAsCompletedRequested({required this.lessonId, required this.courseId});

  @override
  List<Object?> get props => [lessonId, courseId];
}

class InternalDownloadProgressUpdated extends LessonEvent {
  final double progress;
  const InternalDownloadProgressUpdated(this.progress);
  @override
  List<Object?> get props => [progress];
}
