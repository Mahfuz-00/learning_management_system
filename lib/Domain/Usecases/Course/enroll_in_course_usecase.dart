import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Repositories/course_repository.dart';

class EnrollInCourseUseCase {
  final CourseRepository repository;

  const EnrollInCourseUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String courseId) {
    return repository.enrollInCourse(courseId);
  }
}
