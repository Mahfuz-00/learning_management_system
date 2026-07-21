import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final int role; // 0: Student, 1: Teacher
  final String? profilePicture;
  final String? status; // For Teacher approval check

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.profilePicture,
    this.status,
  });

  bool get isStudent => role == 0;
  bool get isTeacher => role == 1;
  bool get isTeacherApproved => role == 1 && status == 'Approved';

  @override
  List<Object?> get props => [id, email, fullName, role, profilePicture, status];
}
