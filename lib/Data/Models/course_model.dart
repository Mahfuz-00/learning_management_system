import '../../Domain/Entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    super.description,
    super.thumbnail,
    required super.price,
    super.instructorName,
    super.totalLessons,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      thumbnail: json['thumbnail'],
      price: (json['price'] ?? 0).toDouble(),
      instructorName: json['instructorName'],
      totalLessons: json['totalLessons'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'price': price,
      'instructorName': instructorName,
      'totalLessons': totalLessons,
    };
  }
}
