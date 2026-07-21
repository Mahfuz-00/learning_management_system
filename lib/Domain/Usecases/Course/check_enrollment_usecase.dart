import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Repositories/course_repository.dart';

class CheckEnrollmentUseCase {
  final CourseRepository repository;

  const CheckEnrollmentUseCase(this.repository);

  Future<Either<Failure, bool>> call(String courseId) {
    return repository.checkEnrollmentStatus(courseId);
  }
}
