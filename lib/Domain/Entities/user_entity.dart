import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String role; // 'Student', 'Teacher', 'Admin'
  final String? name;
  final String? token;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.token,
  });

  @override
  List<Object?> get props => [id, email, role, name, token];
}
