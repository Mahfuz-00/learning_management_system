import '../../Domain/Entities/lesson_entity.dart';

class LessonModel extends LessonEntity {
  const LessonModel({
    required super.id,
    required super.title,
    super.content,
    super.videoUrl,
    super.youtubeUrl,
    required super.isVideo,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'],
      videoUrl: json['videoPath'], // Adjusted based on API docs static file URL format
      youtubeUrl: json['youtubeUrl'],
      isVideo: json['videoPath'] != null || json['youtubeUrl'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'videoPath': videoUrl,
      'youtubeUrl': youtubeUrl,
    };
  }
}
