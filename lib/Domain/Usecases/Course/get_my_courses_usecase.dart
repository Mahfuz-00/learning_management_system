import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Entities/course_entity.dart';
import '../../Repositories/course_repository.dart';

class GetMyCoursesUseCase {
  final CourseRepository repository;

  GetMyCoursesUseCase(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call() {
    return repository.getMyCourses();
  }
}
