import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../Core/Error/exceptions.dart';
import '../../Core/Error/failures.dart';
import '../../Domain/Entities/student_profile_entity.dart';
import '../../Domain/Entities/user_entity.dart';
import '../../Domain/Repositories/auth_repository.dart';
import '../DataSources/auth_local_data_source.dart';
import '../DataSources/auth_remote_data_source.dart';
import '../DataSources/student_remote_data_source.dart';

/// Data-layer implementation of [AuthRepository].
///
/// Responsibilities:
/// 1. Call the remote data source.
/// 2. Persist the JWT and profile in Hive on success.
/// 3. Translate every thrown exception into a domain [Failure] so the BLoC
///    layer never has to handle exceptions.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StudentRemoteDataSource studentRemoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.studentRemoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      if (userModel.token != null && userModel.token!.isNotEmpty) {
        await localDataSource.cacheToken(userModel.token!);
      }
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> register(Map<String, dynamic> signupData) async {
    try {
      // Registration returns the created user, but the student still has to
      // verify their e-mail before they can log in, so the token (if any) is
      // deliberately NOT cached here.
      await remoteDataSource.register(signupData);
      return const Right(unit);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final userModel = await remoteDataSource.getProfile();
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } catch (e) {
      // Offline fallback: serve the last known profile rather than forcing a
      // logout just because the network blipped.
      try {
        final cached = await localDataSource.getUser();
        if (cached != null) return Right(cached);
      } catch (_) {
        // Fall through to the mapped failure below.
      }
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return const Left(CacheFailure('Could not read the saved session.'));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localDataSource.clearCache();
    } catch (e) {
      log('Logout cache clear failed: $e');
    }
  }

  // ── E-mail verification ────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> verifyEmail(String email, String otp) async {
    try {
      await remoteDataSource.verifyEmail(email, otp);
      return const Right(unit);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> resendVerification(String email) async {
    try {
      await remoteDataSource.resendVerification(email);
      return const Right(unit);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  // ── Password recovery ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> requestPasswordReset(String email) async {
    try {
      await remoteDataSource.requestPasswordReset(email);
      return const Right(unit);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyPasswordResetCode(
    String email,
    String code,
  ) async {
    try {
      await remoteDataSource.verifyPasswordResetCode(email, code);
      return const Right(unit);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.resetPassword(email, code, newPassword);
      return const Right(unit);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
      return const Right(unit);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  // ── Student profile ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, StudentProfileEntity>> getStudentProfile() async {
    try {
      final profile = await studentRemoteDataSource.getMyProfile();
      return Right(profile);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> completeOnboarding(
    StudentProfileEntity profile,
  ) async {
    try {
      await studentRemoteDataSource.completeOnboarding(profile.toOnboardingJson());
      return const Right(unit);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateStudentProfile(
    StudentProfileEntity profile,
  ) async {
    try {
      await studentRemoteDataSource.updateProfile(profile.toUpdateJson());
      return const Right(unit);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  // ── Teacher invitation ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, Map<String, dynamic>>> resolveInvite(String token) async {
    try {
      final data = await remoteDataSource.resolveInvite(token);
      return Right(data);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  /// Translates a data-layer exception into the matching domain [Failure].
  ///
  /// Keeping this in one place is what guarantees the same underlying problem
  /// always produces the same user-facing message across every screen.
  Failure _mapException(Object error) {
    if (error is RateLimitFailure) return error;
    if (error is AuthException) return AuthFailure(error.message);
    if (error is NetworkException) return NetworkFailure(error.message);
    if (error is CacheException) return CacheFailure(error.message);
    if (error is ServerException) {
      // Rule 13: surface the rate-limit as its own failure so the UI can show
      // a countdown instead of "wrong password".
      if (error.statusCode == 429) {
        return RateLimitFailure(
          retryAfterSeconds: error.retryAfterSeconds ?? 60,
          message: error.message,
        );
      }
      if (error.statusCode == 404) return NotFoundFailure(error.message);
      return ServerFailure(error.message, statusCode: error.statusCode);
    }
    final message = error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Exception', '');
    return ServerFailure(message.trim());
  }
}