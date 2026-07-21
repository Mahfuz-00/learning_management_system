import '../../Domain/Entities/lesson_entity.dart';

class LessonModel extends LessonEntity {
  const LessonModel({
    required super.id,
    required super.courseId,
    required super.title,
    super.content,
    super.videoUrl,
    super.youtubeUrl,
    super.isCompleted,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: (json['id'] ?? json['guid'] ?? '').toString(),
      courseId: (json['courseId'] ?? '').toString(),
      title: json['title'] ?? '',
      content: json['description'] ?? json['content'],
      videoUrl: json['videoPath'] ?? json['videoUrl'],
      youtubeUrl: json['videoType'] == 'YouTube' ? json['videoUrl'] : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': content,
      'videoPath': videoUrl,
      'youtubeUrl': youtubeUrl,
      'isCompleted': isCompleted,
    };
  }
}
