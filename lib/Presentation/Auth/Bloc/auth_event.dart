import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String role;
  final String name;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.role,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, role, name];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
