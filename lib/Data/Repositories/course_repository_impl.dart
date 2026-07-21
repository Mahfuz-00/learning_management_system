import 'package:dartz/dartz.dart';
import 'dart:io';
import '../../Core/Error/failures.dart';
import '../../Domain/Entities/course_entity.dart';
import '../../Domain/Entities/lesson_entity.dart';
import '../../Domain/Entities/quiz_entity.dart';
import '../../Domain/Entities/live_class_entity.dart';
import '../../Domain/Entities/certificate_entity.dart';
import '../../Domain/Entities/store_item_entity.dart';
import '../../Domain/Entities/comment_entity.dart';
import '../../Domain/Entities/rating_entity.dart';
import '../../Domain/Entities/user_preference_entity.dart';
import '../../Domain/Repositories/course_repository.dart';
import '../DataSources/course_remote_data_source.dart';
import '../DataSources/auth_local_data_source.dart';
import '../Models/user_preference_model.dart';
import '../Models/comment_model.dart';
import 'dart:developer';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  CourseRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<CourseEntity>>> getAllCourses() async {
    try {
      final courses = await remoteDataSource.getAllCourses();
      return Right(courses);
    } catch (e) {
      log('Repo Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> getCourseById(String id) async {
    try {
      final course = await remoteDataSource.getCourseById(id);
      return Right(course);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getMyEnrollments() async {
    try {
      final courses = await remoteDataSource.getMyEnrollments();
      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> enrollInCourse(String courseId) async {
    try {
      await remoteDataSource.enrollInCourse(courseId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEnrollmentStatus(String courseId) async {
    try {
      final status = await remoteDataSource.checkEnrollmentStatus(courseId);
      // Assuming it returns a map with a boolean or similar, based on the check status logic
      // In CourseRemoteDataSource it returns Future<Map<String, dynamic>>
      // If the data exists and is valid, user is enrolled.
      return Right(status.isNotEmpty);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LessonEntity>>> getLessonsByCourse(String courseId) async {
    try {
      final lessons = await remoteDataSource.getLessonsByCourse(courseId);
      return Right(lessons);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleWishlist(String courseId) async {
    try {
      final user = await localDataSource.getUser();
      if (user == null) return Left(AuthFailure('User not logged in'));
      await remoteDataSource.toggleWishlist(courseId, user.id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkWishlist(String courseId) async {
    try {
      final user = await localDataSource.getUser();
      if (user == null) return const Right(false);
      final isWishlisted = await remoteDataSource.checkWishlist(courseId, user.id);
      return Right(isWishlisted);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveVideoProgress(String lessonId, Map<String, dynamic> progressData) async {
    try {
      await remoteDataSource.saveVideoProgress(lessonId, progressData);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getVideoProgress(String lessonId) async {
    try {
      final user = await localDataSource.getUser();
      if (user == null) return Left(AuthFailure('User not logged in'));
      final progress = await remoteDataSource.getVideoProgress(lessonId, user.id);
      return Right(progress);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuizQuestions(String lessonId) async {
    try {
      final questions = await remoteDataSource.getQuizQuestions(lessonId);
      return Right(questions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitQuiz(String lessonId, Map<String, dynamic> answers) async {
    try {
      final user = await localDataSource.getUser();
      if (user == null) return Left(AuthFailure('User not logged in'));
      final payload = {
        'userId': user.id,
        'answers': answers,
      };
      final result = await remoteDataSource.submitQuiz(lessonId, payload);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasAttemptedQuiz(String lessonId) async {
    try {
      final user = await localDataSource.getUser();
      if (user == null) return const Right(false);
      final hasAttempted = await remoteDataSource.hasAttemptedQuiz(lessonId, user.id);
      return Right(hasAttempted);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getQuizLeaderboard() async {
    try {
      final leaderboard = await remoteDataSource.getQuizLeaderboard();
      return Right(leaderboard);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LiveClassEntity>>> getLiveClassesByCourse(String courseId) async {
    try {
      final classes = await remoteDataSource.getLiveClassesByCourse(courseId);
      return Right(classes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> joinLiveClass(String id) async {
    try {
      final data = await remoteDataSource.joinLiveClass(id);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StoreItemEntity>>> getStoreItems() async {
    try {
      final items = await remoteDataSource.getStoreItems();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CertificateEntity>>> getMyCertificates() async {
    try {
      final user = await localDataSource.getUser();
      if (user == null) return Left(AuthFailure('User not logged in'));
      final certificates = await remoteDataSource.getMyCertificates(user.id);
      return Right(certificates);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getTeacherCourses() async {
    try {
      final courses = await remoteDataSource.getTeacherCourses();
      return Right(courses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createCourse(Map<String, dynamic> data) async {
    try {
      final id = await remoteDataSource.createCourse(data);
      return Right(id);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> uploadThumbnail(String id, File image) async {
    try {
      await remoteDataSource.uploadThumbnail(id, image);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createLesson(Map<String, dynamic> data) async {
    try {
      final id = await remoteDataSource.createLesson(data);
      return Right(id);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> uploadLessonVideo(String id, File video) async {
    try {
      await remoteDataSource.uploadLessonVideo(id, video);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setLessonVideoUrl(String id, String url) async {
    try {
      await remoteDataSource.setVideoUrl(id, url);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createLiveClass(Map<String, dynamic> data) async {
    try {
      await remoteDataSource.createLiveClass(data);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getEnrolledStudents(String courseId) async {
    try {
      final students = await remoteDataSource.getEnrolledStudents(courseId);
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addQuizQuestion(String lessonId, Map<String, dynamic> quizData) async {
    try {
      await remoteDataSource.addQuizQuestion(lessonId, quizData);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addRating(Map<String, dynamic> data) async {
    try {
      await remoteDataSource.addRating(data);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRatingSummary(String courseId) async {
    try {
      final summary = await remoteDataSource.getRatingSummary(courseId);
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getCourseComments(String courseId, {int pageNumber = 1, int pageSize = 10}) async {
    try {
      final comments = await remoteDataSource.getCourseComments(courseId, pageNumber, pageSize);
      return Right(comments.map((e) => CommentModel.fromJson(e)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addComment(Map<String, dynamic> data) async {
    try {
      await remoteDataSource.addComment(data);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveUserPreferences(UserPreferenceEntity preferences) async {
    try {
      final model = UserPreferenceModel(
        categories: preferences.categories,
        learningGoal: preferences.learningGoal,
        dailyTime: preferences.dailyTime,
      );
      await localDataSource.cacheUserPreferences(model);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserPreferenceEntity>> getUserPreferences() async {
    try {
      final preferences = await localDataSource.getUserPreferences();
      if (preferences != null) {
        return Right(preferences);
      } else {
        return Left(CacheFailure('No preferences found'));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
