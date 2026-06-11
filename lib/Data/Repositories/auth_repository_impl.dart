import 'package:dartz/dartz.dart';
import '../../Core/Error/failures.dart';
import '../../Domain/Entities/user_entity.dart';
import '../../Domain/Repositories/auth_repository.dart';
import '../DataSources/auth_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Core/Constants/constants.dart';
import 'dart:developer';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    log('Repo: Login attempt for $email');
    try {
      final userModel = await remoteDataSource.login(email, password);
      if (userModel.token != null) {
        log('Repo: Login successful, saving token');
        await sharedPreferences.setString(AppConstants.tokenKey, userModel.token!);
        await sharedPreferences.setString(AppConstants.userRoleKey, userModel.role);
      }
      return Right(userModel);
    } catch (e) {
      log('Repo Error: Login failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String role,
    required String name,
  }) async {
    log('Repo: Register attempt for $email with role $role');
    try {
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        role: role,
        name: name,
      );
      log('Repo: Register successful');
      return Right(userModel);
    } catch (e) {
      log('Repo Error: Register failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    log('Repo: Logout initiated');
    try {
      await sharedPreferences.remove(AppConstants.tokenKey);
      await sharedPreferences.remove(AppConstants.userRoleKey);
      return const Right(null);
    } catch (e) {
      log('Repo Error: Logout failed: $e');
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Option<UserEntity>> getLoggedInUser() async {
    log('Repo: Checking logged in user');
    final token = sharedPreferences.getString(AppConstants.tokenKey);
    final role = sharedPreferences.getString(AppConstants.userRoleKey);
    if (token != null && role != null) {
      log('Repo: User found with role $role');
      return Some(UserEntity(id: '', email: '', role: role, token: token));
    }
    log('Repo: No logged in user found');
    return const None();
  }
}
