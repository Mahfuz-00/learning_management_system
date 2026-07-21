import 'package:equatable/equatable.dart';

class LiveClassEntity extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final DateTime scheduledAt;
  final String? roomUrl;
  final String status; // 'Upcoming', 'Live', 'Ended'

  const LiveClassEntity({
    required this.id,
    required this.courseId,
    required this.title,
    required this.scheduledAt,
    this.roomUrl,
    required this.status,
  });

  bool get isLive => status == 'Live';

  @override
  List<Object?> get props => [id, courseId, title, scheduledAt, roomUrl, status];
}
