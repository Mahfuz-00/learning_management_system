import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Domain/Repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<VerifyResetCodeRequested>(_onVerifyResetCodeRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<ResendVerificationRequested>(_onResendVerificationRequested);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    print('AuthBloc: Checking auth status...');
    try {
      final result = await authRepository.isUserLoggedIn();
      
      bool loggedIn = false;
      result.fold((_) => loggedIn = false, (val) => loggedIn = val);

      if (loggedIn) {
        print('AuthBloc: User is logged in, fetching profile...');
        final profileResult = await authRepository.getProfile();
        profileResult.fold(
          (failure) {
            print('AuthBloc: Profile fetch failed');
            emit(Unauthenticated());
          },
          (user) {
            print('AuthBloc: Authenticated as ${user.fullName}');
            emit(Authenticated(user));
          },
        );
      } else {
        print('AuthBloc: User is not logged in');
        emit(Unauthenticated());
      }
    } catch (e) {
      print('AuthBloc: Auth check error: $e');
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.login(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignupRequested(SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.register(event.signupData);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(SignupSuccess()),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(Unauthenticated());
  }

  /// Step 1 of password recovery — requests a reset code by e-mail.
  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.requestPasswordReset(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(SignupSuccess()),
    );
  }

  /// Confirms the 6-digit code e-mailed after student sign-up (Manual §4.1).
  Future<void> _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.verifyEmail(event.email, event.otp);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(SignupSuccess()),
    );
  }

  /// Step 2 of password recovery — verifies the code sent to the e-mail.
  Future<void> _onVerifyResetCodeRequested(
    VerifyResetCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.verifyPasswordResetCode(
      event.email,
      event.code,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(SignupSuccess()),
    );
  }

  /// Re-sends the e-mail verification code (Manual §4.1).
  ///
  /// The UI enforces the 60-second cooldown before allowing this.
  Future<void> _onResendVerificationRequested(
    ResendVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.resendVerification(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(SignupSuccess()),
    );
  }

  /// Step 3 of password recovery — sets the new password.
  ///
  /// The reset code from step 2 is carried on the event, because the API's
  /// `PUT /api/PasswordReset/reset` requires e-mail + code + new password.
  Future<void> _onResetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.resetPassword(
      event.email,
      event.code,
      event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(SignupSuccess()),
    );
  }
}
