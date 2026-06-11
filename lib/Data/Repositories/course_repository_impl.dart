import 'package:dartz/dartz.dart';
import 'dart:io';
import '../../Core/Error/failures.dart';
import '../../Domain/Entities/course_entity.dart';
import '../../Domain/Entities/lesson_entity.dart';
import '../../Domain/Entities/quiz_entity.dart';
import '../../Domain/Repositories/course_repository.dart';
import '../DataSources/course_remote_data_source.dart';
import 'dart:developer';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CourseEntity>>> getAllCourses() async {
    log('Repo: Fetching all courses');
    try {
      final courses = await remoteDataSource.getAllCourses();
      log('Repo Success: Fetched ${courses.length} courses');
      return Right(courses);
    } catch (e) {
      log('Repo Error: Fetching all courses failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> getCourseById(String id) async {
    log('Repo: Fetching course by id: $id');
    try {
      final course = await remoteDataSource.getCourseById(id);
      log('Repo Success: Fetched course details for ${course.title}');
      return Right(course);
    } catch (e) {
      log('Repo Error: Fetching course failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getMyCourses() async {
    log('Repo: Fetching enrolled courses');
    try {
      final courses = await remoteDataSource.getMyCourses();
      log('Repo Success: Fetched ${courses.length} enrolled courses');
      return Right(courses);
    } catch (e) {
      log('Repo Error: Fetching enrolled courses failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> enrollInCourse(String courseId) async {
    log('Repo: Enrolling in course: $courseId');
    try {
      await remoteDataSource.enrollInCourse(courseId);
      log('Repo Success: Enrollment successful');
      return const Right(null);
    } catch (e) {
      log('Repo Error: Enrollment failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LessonEntity>>> getLessonsByCourse(String courseId) async {
    log('Repo: Fetching lessons for course: $courseId');
    try {
      final lessons = await remoteDataSource.getLessonsByCourse(courseId);
      log('Repo Success: Fetched ${lessons.length} lessons');
      return Right(lessons);
    } catch (e) {
      log('Repo Error: Fetching lessons failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEnrollmentStatus(String courseId) async {
    log('Repo: Checking enrollment status for $courseId');
    try {
      final isEnrolled = await remoteDataSource.checkEnrollmentStatus(courseId);
      log('Repo Success: Enrollment status for $courseId is $isEnrolled');
      return Right(isEnrolled);
    } catch (e) {
      log('Repo Error: Checking enrollment status failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveVideoProgress(String lessonId, double progress) async {
    log('Repo: Saving video progress for lesson $lessonId: $progress');
    try {
      await remoteDataSource.saveVideoProgress(lessonId, progress);
      log('Repo Success: Video progress saved');
      return const Right(null);
    } catch (e) {
      log('Repo Error: Saving video progress failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizEntity>> getQuizByLesson(String lessonId) async {
    log('Repo: Fetching quiz for lesson $lessonId');
    try {
      final quiz = await remoteDataSource.getQuizByLesson(lessonId);
      log('Repo Success: Fetched quiz ${quiz.title}');
      return Right(quiz);
    } catch (e) {
      log('Repo Error: Fetching quiz failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitQuizAttempt(String quizId, Map<String, dynamic> answers) async {
    log('Repo: Submitting quiz attempt for quiz $quizId');
    try {
      await remoteDataSource.submitQuizAttempt(quizId, answers);
      log('Repo Success: Quiz attempt submitted');
      return const Right(null);
    } catch (e) {
      log('Repo Error: Submitting quiz attempt failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> createCourse(Map<String, dynamic> courseData) async {
    log('Repo: Creating course');
    try {
      final course = await remoteDataSource.createCourse(courseData);
      log('Repo Success: Course created with id ${course.id}');
      return Right(course);
    } catch (e) {
      log('Repo Error: Creating course failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadThumbnail(String courseId, File thumbnail) async {
    log('Repo: Uploading thumbnail for course $courseId');
    try {
      await remoteDataSource.uploadThumbnail(courseId, thumbnail);
      log('Repo Success: Thumbnail uploaded');
      return const Right(null);
    } catch (e) {
      log('Repo Error: Uploading thumbnail failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LessonEntity>> createLesson(Map<String, dynamic> lessonData) async {
    log('Repo: Creating lesson');
    try {
      final lesson = await remoteDataSource.createLesson(lessonData);
      log('Repo Success: Lesson created with id ${lesson.id}');
      return Right(lesson);
    } catch (e) {
      log('Repo Error: Creating lesson failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadLessonVideo(String lessonId, File video) async {
    log('Repo: Uploading video for lesson $lessonId');
    try {
      await remoteDataSource.uploadLessonVideo(lessonId, video);
      log('Repo Success: Video uploaded');
      return const Right(null);
    } catch (e) {
      log('Repo Error: Uploading video failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setLessonYoutubeUrl(String lessonId, String youtubeUrl) async {
    log('Repo: Setting YouTube URL for lesson $lessonId');
    try {
      await remoteDataSource.setLessonYoutubeUrl(lessonId, youtubeUrl);
      log('Repo Success: YouTube URL set');
      return const Right(null);
    } catch (e) {
      log('Repo Error: Setting YouTube URL failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createQuiz(Map<String, dynamic> quizData) async {
    log('Repo: Creating quiz');
    try {
      await remoteDataSource.createQuiz(quizData);
      log('Repo Success: Quiz created');
      return const Right(null);
    } catch (e) {
      log('Repo Error: Creating quiz failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
