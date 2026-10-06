import 'package:dartz/dartz.dart';
import '../../../Core/Error/failures.dart';
import '../../Repositories/course_repository.dart';

/// Determines whether the current student is enrolled in a given course.
///
/// **Why this does not call `Enrollment/by-course/{courseId}`:** that endpoint
/// returns *course-scoped* enrollment information (who is in the course), not
/// the current user's own status. Using it as a per-user boolean — as the
/// previous implementation did — would report a course as "enrolled" for any
/// student as soon as anybody had joined it.
///
/// The correct source is the authenticated student's own enrollment list.
class CheckEnrollmentUseCase {
  final CourseRepository repository;

  const CheckEnrollmentUseCase(this.repository);

  /// Returns true when [courseId] appears in the student's own enrollments.
  Future<Either<Failure, bool>> call(String courseId) async {
    final result = await repository.getMyEnrollments();
    return result.map(
      (courses) => courses.any((course) => course.id == courseId),
    );
  }
}
