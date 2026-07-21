import 'package:equatable/equatable.dart';

abstract class LessonState extends Equatable {
  const LessonState();

  @override
  List<Object?> get props => [];
}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

class VideoDownloadInProgress extends LessonState {
  final double progress;
  const VideoDownloadInProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class VideoDownloaded extends LessonState {
  final String localPath;
  const VideoDownloaded(this.localPath);

  @override
  List<Object?> get props => [localPath];
}

class VideoNotDownloaded extends LessonState {}

class LessonCompleted extends LessonState {}

class LessonError extends LessonState {
  final String message;
  const LessonError(this.message);

  @override
  List<Object?> get props => [message];
}
