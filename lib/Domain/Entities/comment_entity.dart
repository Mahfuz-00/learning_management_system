import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String courseId;
  final String userId;
  final String userName;
  final String? userProfilePicture;
  final String content;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.userName,
    this.userProfilePicture,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, courseId, userId, userName, userProfilePicture, content, createdAt];
}
