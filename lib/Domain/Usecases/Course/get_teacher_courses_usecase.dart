import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Entities/course_entity.dart';
import '../../Repositories/course_repository.dart';

class GetTeacherCoursesUseCase {
  final CourseRepository repository;

  const GetTeacherCoursesUseCase(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call() {
    return repository.getTeacherCourses();
  }
}
