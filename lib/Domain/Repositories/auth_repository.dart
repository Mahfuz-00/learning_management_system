import 'package:dartz/dartz.dart';
import '../../Core/Error/failures.dart';
import '../Entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String role,
    required String name,
  });
  Future<Either<Failure, void>> logout();
  Future<Option<UserEntity>> getLoggedInUser();
}
