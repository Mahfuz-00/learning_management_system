import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Entities/course_entity.dart';
import '../../Repositories/course_repository.dart';

class GetCourseByIdUseCase {
  final CourseRepository repository;

  const GetCourseByIdUseCase(this.repository);

  Future<Either<Failure, CourseEntity>> call(String id) {
    return repository.getCourseById(id);
  }
}
