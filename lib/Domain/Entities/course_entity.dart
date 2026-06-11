import 'package:equatable/equatable.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? thumbnail;
  final double price;
  final String? instructorName;
  final int? totalLessons;

  const CourseEntity({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    required this.price,
    this.instructorName,
    this.totalLessons,
  });

  @override
  List<Object?> get props => [id, title, description, thumbnail, price, instructorName, totalLessons];
}
