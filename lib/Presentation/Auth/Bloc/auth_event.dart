import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignupRequested extends AuthEvent {
  final Map<String, dynamic> signupData;

  const SignupRequested(this.signupData);

  @override
  List<Object?> get props => [signupData];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  const VerifyOtpRequested({required this.email, required this.otp});
  @override
  List<Object?> get props => [email, otp];
}

/// Step 3 of password recovery — set the new password.
///
/// Carries the reset [code] obtained in step 2, because the live
/// `PUT /api/PasswordReset/reset` endpoint requires e-mail + code + password.
class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String code;
  final String password;
  const ResetPasswordRequested({
    required this.email,
    required this.code,
    required this.password,
  });

  @override
  List<Object?> get props => [email, code, password];
}

/// Step 2 of password recovery — verify the reset code.
class VerifyResetCodeRequested extends AuthEvent {
  final String email;
  final String code;
  const VerifyResetCodeRequested({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

/// Re-sends the e-mail verification code (Manual §4.1 — available after 60s).
class ResendVerificationRequested extends AuthEvent {
  final String email;
  const ResendVerificationRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class LogoutRequested extends AuthEvent {}
