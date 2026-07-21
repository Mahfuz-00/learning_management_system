import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Entities/quiz_entity.dart';
import '../../Repositories/course_repository.dart';

class GetQuizQuestionsUseCase {
  final CourseRepository repository;

  const GetQuizQuestionsUseCase(this.repository);

  Future<Either<Failure, List<QuestionEntity>>> call(String lessonId) {
    return repository.getQuizQuestions(lessonId);
  }
}
