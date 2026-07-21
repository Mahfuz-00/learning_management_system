import '../../Domain/Entities/user_entity.dart';

class UserModel extends UserEntity {
  final String? token;
  final String? message;

  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.profilePicture,
    super.status,
    this.token,
    this.message,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Login and Register return flat user objects in the root or sometimes nested.
    // Based on docs: {"message": "...", "token": "...", "userId": "...", "fullName": "...", "role": 0}
    return UserModel(
      id: (json['userId'] ?? json['id'] ?? '').toString(),
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      role: json['role'] ?? 0,
      profilePicture: json['profileImagePath'] ?? json['profilePicture'],
      status: json['status'],
      token: json['token'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'profilePicture': profilePicture,
      'status': status,
      'token': token,
    };
  }
}
