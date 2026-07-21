import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Entities/lesson_entity.dart';
import '../../Repositories/course_repository.dart';

class GetLessonsByCourseUseCase {
  final CourseRepository repository;

  const GetLessonsByCourseUseCase(this.repository);

  Future<Either<Failure, List<LessonEntity>>> call(String courseId) {
    return repository.getLessonsByCourse(courseId);
  }
}
