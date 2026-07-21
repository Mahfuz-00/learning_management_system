import 'package:equatable/equatable.dart';
import 'lesson_entity.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? thumbnail;
  final double price;
  final String? instructorName;
  final int totalLessons;
  final bool isEnrolled;
  final bool isWishlisted;
  final List<LessonEntity> lessons;

  const CourseEntity({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    required this.price,
    this.instructorName,
    this.totalLessons = 0,
    this.isEnrolled = false,
    this.isWishlisted = false,
    this.lessons = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        thumbnail,
        price,
        instructorName,
        totalLessons,
        isEnrolled,
        isWishlisted,
        lessons,
      ];
}
