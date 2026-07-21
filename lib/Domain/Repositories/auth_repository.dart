import 'package:dartz/dartz.dart';
import '../../Core/Error/failures.dart';
import '../Entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, Unit>> register(Map<String, dynamic> signupData);
  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, bool>> isUserLoggedIn();
  Future<void> logout();
  
  // Password Recovery
  Future<Either<Failure, Unit>> forgotPassword(String email);
  Future<Either<Failure, Unit>> verifyOtp(String email, String otp);
  Future<Either<Failure, Unit>> resetPassword(String email, String password);
}
