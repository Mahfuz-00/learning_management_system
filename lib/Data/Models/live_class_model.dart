import '../../Domain/Entities/live_class_entity.dart';

class LiveClassModel extends LiveClassEntity {
  const LiveClassModel({
    required super.id,
    required super.courseId,
    required super.title,
    required super.scheduledAt,
    super.roomUrl,
    required super.status,
  });

  factory LiveClassModel.fromJson(Map<String, dynamic> json) {
    return LiveClassModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      title: json['title'] ?? '',
      scheduledAt: DateTime.parse(json['scheduledAt'] ?? DateTime.now().toIso8601String()),
      roomUrl: json['roomUrl'],
      status: json['status'] ?? 'Upcoming',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'scheduledAt': scheduledAt.toIso8601String(),
      'roomUrl': roomUrl,
      'status': status,
    };
  }
}
