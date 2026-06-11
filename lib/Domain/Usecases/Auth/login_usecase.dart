import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Entities/user_entity.dart';
import '../../Repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}
