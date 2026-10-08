// Unit tests for AuthBloc — the authentication state machine.
//
// These drive the real bloc through its events and assert the emitted states,
// using FakeAuthRepository so no network is involved.

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Core/Error/failures.dart';
import 'package:lms_touch_and_solve/Domain/Entities/user_entity.dart';
import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/auth_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/auth_event.dart';
import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/auth_state.dart';

import '../helpers/fakes.dart';

void main() {
  const user = UserEntity(
    id: 'u1',
    email: 'student@nirvoor.com',
    fullName: 'Test Student',
    role: 0,
  );

  group('AuthBloc — login', () {
    test('emits AuthLoading then Authenticated on success', () async {
      final repo = FakeAuthRepository(loginResult: const Right(user));
      final bloc = AuthBloc(authRepository: repo);
      addTearDown(bloc.close);

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoginRequested(
        email: 'student@nirvoor.com',
        password: 'secret',
      ));
      await bloc.stream.firstWhere((s) => s is Authenticated);
      await sub.cancel();

      expect(states.whereType<AuthLoading>(), isNotEmpty);
      expect(states.last, isA<Authenticated>());
      expect((states.last as Authenticated).user.id, 'u1');
      expect(repo.loginCalls, ['student@nirvoor.com:secret']);
    });

    test('emits AuthError carrying the failure message on bad credentials',
        () async {
      final repo = FakeAuthRepository(
        loginResult: const Left(AuthFailure('Invalid email or password.')),
      );
      final bloc = AuthBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(const LoginRequested(email: 'a@b.com', password: 'wrong'));

      final error = await bloc.stream.firstWhere((s) => s is AuthError);
      expect((error as AuthError).message, 'Invalid email or password.');
    });

    test('a RateLimitFailure message reaches the UI unchanged', () async {
      final repo = FakeAuthRepository(
        loginResult: const Left(RateLimitFailure(retryAfterSeconds: 60)),
      );
      final bloc = AuthBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(const LoginRequested(email: 'a@b.com', password: 'x'));

      final error = await bloc.stream.firstWhere((s) => s is AuthError);
      expect(
        (error as AuthError).message.toLowerCase(),
        contains('too many attempts'),
      );
    });
  });

  group('AuthBloc — session check', () {
    test('emits Authenticated when a token exists and the profile loads',
        () async {
      final repo = FakeAuthRepository(
        loggedInResult: const Right(true),
        profileResult: const Right(user),
      );
      final bloc = AuthBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(AuthCheckRequested());

      final state = await bloc.stream.firstWhere((s) => s is Authenticated);
      expect((state as Authenticated).user.fullName, 'Test Student');
      expect(repo.profileCalls, 1);
    });

    test('emits Unauthenticated when no token is cached', () async {
      final repo = FakeAuthRepository(loggedInResult: const Right(false));
      final bloc = AuthBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(AuthCheckRequested());

      expect(await bloc.stream.firstWhere((s) => s is Unauthenticated),
          isA<Unauthenticated>());
      // No token -> the profile must not be fetched.
      expect(repo.profileCalls, 0);
    });

    test('emits Unauthenticated when the profile fetch fails', () async {
      final repo = FakeAuthRepository(
        loggedInResult: const Right(true),
        profileResult: const Left(ServerFailure('boom')),
      );
      final bloc = AuthBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(AuthCheckRequested());

      expect(await bloc.stream.firstWhere((s) => s is Unauthenticated),
          isA<Unauthenticated>());
    });
  });

  group('AuthBloc — signup, logout and password recovery', () {
    test('signup success emits SignupSuccess', () async {
      final repo = FakeAuthRepository(registerResult: const Right(unit));
      final bloc = AuthBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(const SignupRequested({'email': 'a@b.com', 'role': 0}));

      expect(await bloc.stream.firstWhere((s) => s is SignupSuccess),
          isA<SignupSuccess>());
      expect(repo.registerCalls.single['email'], 'a@b.com');
    });

    test('signup failure emits AuthError', () async {
      final repo = FakeAuthRepository(
        registerResult: const Left(ServerFailure('Email already used')),
      );
      final bloc = AuthBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(const SignupRequested({'email': 'a@b.com'}));

      final error = await bloc.stream.firstWhere((s) => s is AuthError);
      expect((error as AuthError).message, 'Email already used');
    });

    test('logout clears the session and emits Unauthenticated', () async {
      final repo = FakeAuthRepository();
      final bloc = AuthBloc(authRepository: repo);
      addTearDown(bloc.close);

      bloc.add(LogoutRequested());

      expect(await bloc.stream.firstWhere((s) => s is Unauthenticated),
          isA<Unauthenticated>());
      expect(repo.logoutCalls, 1);
    });
  });
}
