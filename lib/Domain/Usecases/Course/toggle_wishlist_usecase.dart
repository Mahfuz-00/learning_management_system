import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Repositories/course_repository.dart';

class ToggleWishlistUseCase {
  final CourseRepository repository;

  const ToggleWishlistUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String courseId) {
    return repository.toggleWishlist(courseId);
  }
}
