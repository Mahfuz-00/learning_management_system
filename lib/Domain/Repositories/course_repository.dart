import 'package:dartz/dartz.dart';
import 'dart:io';
import '../../Core/Error/failures.dart';
import '../Entities/course_entity.dart';
import '../Entities/lesson_entity.dart';
import '../Entities/quiz_entity.dart';
import '../Entities/live_class_entity.dart';
import '../Entities/certificate_entity.dart';
import '../Entities/store_item_entity.dart';
import '../Entities/comment_entity.dart';
import '../Entities/rating_entity.dart';
import '../Entities/user_preference_entity.dart';

abstract class CourseRepository {
  // Common & Student Actions
  Future<Either<Failure, List<CourseEntity>>> getAllCourses();
  Future<Either<Failure, CourseEntity>> getCourseById(String id);
  Future<Either<Failure, List<CourseEntity>>> getMyEnrollments();
  Future<Either<Failure, Unit>> enrollInCourse(String courseId);
  Future<Either<Failure, bool>> checkEnrollmentStatus(String courseId);
  Future<Either<Failure, List<LessonEntity>>> getLessonsByCourse(String courseId);
  Future<Either<Failure, Unit>> toggleWishlist(String courseId);
  Future<Either<Failure, bool>> checkWishlist(String courseId);
  Future<Either<Failure, void>> saveVideoProgress(String lessonId, Map<String, dynamic> progressData);
  Future<Either<Failure, Map<String, dynamic>>> getVideoProgress(String lessonId);
  
  // Quiz Actions
  Future<Either<Failure, List<QuestionEntity>>> getQuizQuestions(String lessonId);
  Future<Either<Failure, Map<String, dynamic>>> submitQuiz(String lessonId, Map<String, dynamic> answers);
  Future<Either<Failure, bool>> hasAttemptedQuiz(String lessonId);
  Future<Either<Failure, List<dynamic>>> getQuizLeaderboard();
  
  // Live Class Actions
  Future<Either<Failure, List<LiveClassEntity>>> getLiveClassesByCourse(String courseId);
  Future<Either<Failure, Map<String, dynamic>>> joinLiveClass(String id);

  // Store Actions
  Future<Either<Failure, List<StoreItemEntity>>> getStoreItems();

  // Certificate Actions
  Future<Either<Failure, List<CertificateEntity>>> getMyCertificates();

  // Teacher Actions
  Future<Either<Failure, List<CourseEntity>>> getTeacherCourses();
  Future<Either<Failure, String>> createCourse(Map<String, dynamic> data);
  Future<Either<Failure, Unit>> uploadThumbnail(String id, File image);
  Future<Either<Failure, String>> createLesson(Map<String, dynamic> data);
  Future<Either<Failure, Unit>> uploadLessonVideo(String id, File video);
  Future<Either<Failure, Unit>> setLessonVideoUrl(String id, String url);
  Future<Either<Failure, Unit>> createLiveClass(Map<String, dynamic> data);
  Future<Either<Failure, List<dynamic>>> getEnrolledStudents(String courseId);
  Future<Either<Failure, Unit>> addQuizQuestion(String lessonId, Map<String, dynamic> quizData);

  // Rating & Comments
  Future<Either<Failure, Unit>> addRating(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> getRatingSummary(String courseId);
  Future<Either<Failure, List<CommentEntity>>> getCourseComments(String courseId, {int pageNumber = 1, int pageSize = 10});
  Future<Either<Failure, Unit>> addComment(Map<String, dynamic> data);

  // Preferences
  Future<Either<Failure, Unit>> saveUserPreferences(UserPreferenceEntity preferences);
  Future<Either<Failure, UserPreferenceEntity>> getUserPreferences();
}
