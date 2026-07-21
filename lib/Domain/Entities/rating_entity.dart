import 'package:equatable/equatable.dart';

class RatingEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userProfilePicture;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;

  const RatingEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfilePicture,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, userName, userProfilePicture, rating, comment, createdAt];
}
