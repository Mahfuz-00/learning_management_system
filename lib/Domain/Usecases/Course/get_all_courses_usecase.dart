import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Entities/course_entity.dart';
import '../../Repositories/course_repository.dart';

class GetAllCoursesUseCase {
  final CourseRepository repository;

  GetAllCoursesUseCase(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call() {
    return repository.getAllCourses();
  }
}
