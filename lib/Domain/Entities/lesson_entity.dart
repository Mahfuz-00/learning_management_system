import 'package:equatable/equatable.dart';

class LessonEntity extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String? content;
  final String? videoUrl; // Recorded video path
  final String? youtubeUrl;
  final bool isCompleted;

  const LessonEntity({
    required this.id,
    required this.courseId,
    required this.title,
    this.content,
    this.videoUrl,
    this.youtubeUrl,
    this.isCompleted = false,
  });

  bool get hasVideo => (videoUrl != null && videoUrl!.isNotEmpty) || (youtubeUrl != null && youtubeUrl!.isNotEmpty);
  bool get isYoutube => youtubeUrl != null && youtubeUrl!.isNotEmpty;

  @override
  List<Object?> get props => [id, courseId, title, content, videoUrl, youtubeUrl, isCompleted];
}
