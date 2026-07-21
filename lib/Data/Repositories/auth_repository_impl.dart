import 'package:dartz/dartz.dart';
import '../../Core/Error/failures.dart';
import '../../Domain/Entities/user_entity.dart';
import '../../Domain/Repositories/auth_repository.dart';
import '../DataSources/auth_local_data_source.dart';
import '../DataSources/auth_remote_data_source.dart';
import '../Models/user_model.dart';
import 'dart:developer';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      if (userModel.token != null) {
        await localDataSource.cacheToken(userModel.token!);
      }
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } catch (e) {
      log('AuthRepo Error: $e');
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> register(Map<String, dynamic> signupData) async {
    try {
      await remoteDataSource.register(signupData);
      return const Right(unit);
    } catch (e) {
      log('AuthRepo Error: $e');
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final userModel = await remoteDataSource.getProfile();
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } catch (e) {
      final localUser = await localDataSource.getUser();
      if (localUser != null) {
        return Right(localUser);
      }
      return Left(CacheFailure('No cached user found'));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return const Left(CacheFailure('Error checking login status'));
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearCache();
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp(String email, String otp) async {
    try {
      await remoteDataSource.verifyOtp(email, otp);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(String email, String password) async {
    try {
      await remoteDataSource.resetPassword(email, password);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
