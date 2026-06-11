import 'package:dartz/dartz.dart';
import 'dart:io';
import '../../Core/Error/failures.dart';
import '../Entities/course_entity.dart';
import '../Entities/lesson_entity.dart';
import '../Entities/quiz_entity.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<CourseEntity>>> getAllCourses();
  Future<Either<Failure, CourseEntity>> getCourseById(String id);
  Future<Either<Failure, List<CourseEntity>>> getMyCourses();
  Future<Either<Failure, void>> enrollInCourse(String courseId);
  Future<Either<Failure, List<LessonEntity>>> getLessonsByCourse(String courseId);
  Future<Either<Failure, bool>> checkEnrollmentStatus(String courseId);
  Future<Either<Failure, void>> saveVideoProgress(String lessonId, double progress);
  Future<Either<Failure, QuizEntity>> getQuizByLesson(String lessonId);
  Future<Either<Failure, void>> submitQuizAttempt(String quizId, Map<String, dynamic> answers);

  // Teacher Actions
  Future<Either<Failure, CourseEntity>> createCourse(Map<String, dynamic> courseData);
  Future<Either<Failure, void>> uploadThumbnail(String courseId, File thumbnail);
  Future<Either<Failure, LessonEntity>> createLesson(Map<String, dynamic> lessonData);
  Future<Either<Failure, void>> uploadLessonVideo(String lessonId, File video);
  Future<Either<Failure, void>> setLessonYoutubeUrl(String lessonId, String youtubeUrl);
  Future<Either<Failure, void>> createQuiz(Map<String, dynamic> quizData);
}
