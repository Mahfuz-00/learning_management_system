import 'package:equatable/equatable.dart';

class LessonEntity extends Equatable {
  final String id;
  final String title;
  final String? content;
  final String? videoUrl;
  final String? youtubeUrl;
  final bool isVideo;

  const LessonEntity({
    required this.id,
    required this.title,
    this.content,
    this.videoUrl,
    this.youtubeUrl,
    required this.isVideo,
  });

  @override
  List<Object?> get props => [id, title, content, videoUrl, youtubeUrl, isVideo];
}
