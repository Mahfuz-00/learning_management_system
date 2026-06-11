import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Domain/UseCases/Auth/login_usecase.dart';
import '../../../Domain/UseCases/Auth/register_usecase.dart';
import '../../../Domain/Repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:developer';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    log('Bloc: LoginRequested for ${event.email}');
    emit(AuthLoading());
    final result = await loginUseCase(event.email, event.password);
    result.fold(
      (failure) {
        log('Bloc Error: Login failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        log('Bloc Success: User authenticated: ${user.email}');
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    log('Bloc: RegisterRequested for ${event.email}');
    emit(AuthLoading());
    final result = await registerUseCase(
      email: event.email,
      password: event.password,
      role: event.role,
      name: event.name,
    );
    result.fold(
      (failure) {
        log('Bloc Error: Register failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        log('Bloc Success: User registered: ${user.email}');
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    log('Bloc: LogoutRequested');
    emit(AuthLoading());
    await authRepository.logout();
    emit(Unauthenticated());
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    log('Bloc: CheckAuthStatus');
    final userOption = await authRepository.getLoggedInUser();
    userOption.fold(
      () {
        log('Bloc: User is unauthenticated');
        emit(Unauthenticated());
      },
      (user) {
        log('Bloc: User is authenticated as ${user.role}');
        emit(Authenticated(user));
      },
    );
  }
}
