import '../../Domain/Entities/course_entity.dart';
import 'lesson_model.dart';

class CourseModel extends CourseEntity {
  final String? category;
  final String? level;
  final int? durationMinutes;
  final bool? isPublished;
  final String? createdAt;

  const CourseModel({
    required super.id,
    required super.title,
    super.description,
    super.thumbnail,
    required super.price,
    super.instructorName,
    super.totalLessons,
    super.isEnrolled,
    super.isWishlisted,
    super.lessons,
    this.category,
    this.level,
    this.durationMinutes,
    this.isPublished,
    this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: (json['id'] ?? json['courseId'] ?? '').toString(),
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'],
      level: json['level'],
      price: (json['price'] ?? 0).toDouble(),
      durationMinutes: json['durationMinutes'],
      thumbnail: json['thumbnailPath'],
      isPublished: json['isPublished'],
      instructorName: json['instructorName'],
      totalLessons: json['lessonCount'] ?? json['totalLessons'] ?? 0,
      createdAt: json['createdAt'],
      isEnrolled: json['isEnrolled'] ?? false,
      isWishlisted: json['isWishlisted'] ?? false,
      lessons: (json['lessons'] as List? ?? [])
          .map((e) => LessonModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      'price': price,
      'durationMinutes': durationMinutes,
      'thumbnailPath': thumbnail,
      'isPublished': isPublished,
      'instructorName': instructorName,
      'lessonCount': totalLessons,
      'isEnrolled': isEnrolled,
      'isWishlisted': isWishlisted,
    };
  }
}
