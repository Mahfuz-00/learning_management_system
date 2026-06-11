import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Entities/user_entity.dart';
import '../../Repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String role,
    required String name,
  }) {
    return repository.register(
      email: email,
      password: password,
      role: role,
      name: name,
    );
  }
}
