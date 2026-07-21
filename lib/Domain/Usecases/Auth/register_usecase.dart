import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String email,
    required String password,
    required int role,
    required String name,
  }) {
    return repository.register({
      'email': email,
      'password': password,
      'role': role,
      'fullName': name,
    });
  }
}
