import 'dart:io';
import 'package:dio/dio.dart';
import '../../Core/Constants/api_routes.dart';
import '../../Core/Error/exceptions.dart';
import '../Models/certificate_model.dart';
import '../Models/course_model.dart';
import '../Models/json_utils.dart';
import '../Models/lesson_model.dart';
import '../Models/live_class_model.dart';
import '../Models/quiz_model.dart';
import '../Models/store_item_model.dart';

/// Remote contract for courses, lessons, enrollment, quizzes, live classes,
/// wishlist, certificates, ratings and comments.
///
/// **Every route now comes from [ApiRoutes].** The previous version hard-coded
/// strings inline, several of which did not match the live API (for example a
/// student's own enrollment status was read from the *course-scoped*
/// `Enrollment/by-course` endpoint). All paths were re-verified against the
/// live OpenAPI document.
abstract class CourseRemoteDataSource {
  // ── Course endpoints ──────────────────────────────────────────────────
  Future<List<CourseModel>> getAllCourses();
  Future<List<CourseModel>> getTeacherCourses();
  Future<CourseModel> getCourseById(String id);
  Future<String> createCourse(Map<String, dynamic> data);
  Future<void> updateCourse(String id, Map<String, dynamic> data);
  Future<void> deleteCourse(String id);
  Future<void> uploadThumbnail(String id, File image);

  /// Real vs. marketing counts for the course **details** page (Rule 5).
  Future<Map<String, dynamic>> getCourseStats(String id);

  // ── Lesson endpoints ──────────────────────────────────────────────────
  Future<List<LessonModel>> getLessonsByCourse(String courseId);
  Future<LessonModel> getLessonById(String id);
  Future<String> createLesson(Map<String, dynamic> data);
  Future<void> updateLesson(String id, Map<String, dynamic> data);
  Future<void> deleteLesson(String id);
  Future<void> uploadLessonVideo(String id, File video);
  Future<void> setVideoUrl(String id, String url);
  Future<void> uploadLessonThumbnail(String id, File image);

  // ── Enrollment endpoints ──────────────────────────────────────────────
  Future<void> enrollInCourse(String courseId);
  Future<List<CourseModel>> getMyEnrollments();
  Future<List<dynamic>> getEnrolledStudents(String courseId);
  Future<Map<String, dynamic>> getEnrollmentCount(String courseId);

  // ── Quiz endpoints ────────────────────────────────────────────────────
  Future<List<QuestionModel>> getQuizQuestions(String lessonId);
  Future<void> addQuizQuestion(String lessonId, Map<String, dynamic> quizData);
  Future<void> deleteQuizQuestion(String quizId);
  Future<Map<String, dynamic>> submitQuiz(String lessonId, Map<String, dynamic> payload);
  Future<bool> hasAttemptedQuiz(String lessonId, String userId);
  Future<List<dynamic>> getQuizLeaderboard();

  // ── Video progress ────────────────────────────────────────────────────
  Future<void> saveVideoProgress(String lessonId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> getVideoProgress(String lessonId, String userId);

  // ── Live class endpoints ──────────────────────────────────────────────
  Future<void> createLiveClass(Map<String, dynamic> data);
  Future<void> startLiveClass(String id);
  Future<void> endLiveClass(String id);
  Future<Map<String, dynamic>> joinLiveClass(String id);
  Future<List<LiveClassModel>> getLiveClassesByCourse(String courseId);
  Future<List<LiveClassModel>> getRecordingsByCourse(String courseId);

  /// Teacher uploads a browser-recorded file (Rule 11).
  Future<void> uploadRecording(String liveClassId, File file);

  // ── Store endpoints ───────────────────────────────────────────────────
  Future<List<StoreItemModel>> getStoreItems();
  Future<void> addStoreItem(Map<String, dynamic> data);
  Future<void> uploadStoreItemPdf(String id, File pdf);
  Future<void> deleteStoreItem(String id);

  // ── Wishlist endpoints ────────────────────────────────────────────────
  Future<void> toggleWishlist(String courseId, String userId);
  Future<bool> checkWishlist(String courseId, String userId);
  Future<List<CourseModel>> getMyWishlist(String userId);

  // ── Certificate endpoints ─────────────────────────────────────────────
  Future<void> issueCertificate(Map<String, dynamic> data);
  Future<List<CertificateModel>> getMyCertificates(String userId);
  Future<List<CertificateModel>> getCourseCertificates(String courseId);

  // ── Instructor endpoints ──────────────────────────────────────────────
  Future<List<dynamic>> getAllInstructors();
  Future<Map<String, dynamic>> getInstructorProfile(String teacherId);
  Future<void> updateTeacherProfile(Map<String, dynamic> data);
  Future<void> uploadProfileImage(File file);

  // ── Rating endpoints ──────────────────────────────────────────────────
  Future<void> addRating(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getRatingSummary(String courseId);
  Future<void> deleteRating(String ratingId, String userId);

  // ── Comment endpoints ─────────────────────────────────────────────────
  Future<List<dynamic>> getCourseComments(String courseId, int pageNumber, int pageSize);
  Future<void> addComment(Map<String, dynamic> data);
  Future<void> updateComment(String id, String content);
  Future<void> deleteComment(String id);
}

/// Dio-backed implementation of [CourseRemoteDataSource].
class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final Dio dio;

  CourseRemoteDataSourceImpl({required this.dio});

  // ── Courses ───────────────────────────────────────────────────────────

  @override
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final response = await dio.get(ApiRoutes.allCourses);
      return JsonUtils.toList(
        JsonUtils.unwrapList(response.data),
        CourseModel.fromJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<CourseModel>> getTeacherCourses() async {
    try {
      final response = await dio.get(ApiRoutes.teacherCourses);
      return JsonUtils.toList(
        JsonUtils.unwrapList(response.data),
        CourseModel.fromJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    try {
      final response = await dio.get(ApiRoutes.courseById(id));
      return CourseModel.fromJson(JsonUtils.unwrapMap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<String> createCourse(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiRoutes.createCourse, data: data);
      final map = JsonUtils.unwrapMap(response.data);
      return (map['id'] ?? map['courseId'] ?? response.data).toString();
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    try {
      await dio.put(ApiRoutes.updateCourse(id), data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    try {
      await dio.delete(ApiRoutes.deleteCourse(id));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> uploadThumbnail(String id, File image) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: _fileName(image),
        ),
      });
      await dio.post(ApiRoutes.uploadCourseThumbnail(id), data: formData);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getCourseStats(String id) async {
    try {
      final response = await dio.get(ApiRoutes.courseStats(id));
      return JsonUtils.unwrapMap(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Lessons ───────────────────────────────────────────────────────────

  @override
  Future<List<LessonModel>> getLessonsByCourse(String courseId) async {
    try {
      final response = await dio.get(ApiRoutes.lessonsByCourse(courseId));
      return JsonUtils.toList(
        JsonUtils.unwrapList(response.data),
        LessonModel.fromJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<LessonModel> getLessonById(String id) async {
    try {
      final response = await dio.get(ApiRoutes.lessonById(id));
      return LessonModel.fromJson(JsonUtils.unwrapMap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<String> createLesson(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiRoutes.createLesson, data: data);
      final map = JsonUtils.unwrapMap(response.data);
      return (map['id'] ?? map['lessonId'] ?? response.data).toString();
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> updateLesson(String id, Map<String, dynamic> data) async {
    try {
      await dio.put(ApiRoutes.updateLesson(id), data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteLesson(String id) async {
    try {
      await dio.delete(ApiRoutes.deleteLesson(id));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> uploadLessonVideo(String id, File video) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          video.path,
          filename: _fileName(video),
        ),
      });
      await dio.post(ApiRoutes.uploadLessonVideo(id), data: formData);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> setVideoUrl(String id, String url) async {
    try {
      await dio.post(ApiRoutes.setLessonVideoUrl(id), data: {'videoUrl': url});
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> uploadLessonThumbnail(String id, File image) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: _fileName(image),
        ),
      });
      await dio.post(ApiRoutes.uploadLessonThumbnail(id), data: formData);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Enrollment ────────────────────────────────────────────────────────

  @override
  Future<void> enrollInCourse(String courseId) async {
    try {
      await dio.post(ApiRoutes.enroll, data: {'courseId': courseId});
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<CourseModel>> getMyEnrollments() async {
    try {
      final response = await dio.get(ApiRoutes.myEnrollments);
      return JsonUtils.toList(
        JsonUtils.unwrapList(response.data),
        CourseModel.fromJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<dynamic>> getEnrolledStudents(String courseId) async {
    try {
      final response = await dio.get(ApiRoutes.enrolledStudents(courseId));
      return JsonUtils.unwrapList(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getEnrollmentCount(String courseId) async {
    try {
      final response = await dio.get(ApiRoutes.enrollmentCount(courseId));
      return JsonUtils.unwrapMap(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Quiz ──────────────────────────────────────────────────────────────

  @override
  Future<List<QuestionModel>> getQuizQuestions(String lessonId) async {
    try {
      final response = await dio.get(ApiRoutes.quizByLesson(lessonId));
      return JsonUtils.toList(
        JsonUtils.unwrapList(response.data),
        QuestionModel.fromJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> addQuizQuestion(String lessonId, Map<String, dynamic> quizData) async {
    try {
      await dio.post(ApiRoutes.addQuiz(lessonId), data: quizData);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteQuizQuestion(String quizId) async {
    try {
      await dio.delete(ApiRoutes.deleteQuiz(quizId));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> submitQuiz(
    String lessonId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(ApiRoutes.submitQuiz(lessonId), data: payload);
      return JsonUtils.unwrapMap(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<bool> hasAttemptedQuiz(String lessonId, String userId) async {
    try {
      final response = await dio.get(ApiRoutes.hasAttemptedQuiz(lessonId, userId));
      final map = JsonUtils.unwrapMap(response.data);
      return JsonUtils.toBool(
        response.data is bool ? response.data : (map['data'] ?? map['hasAttempted']),
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<dynamic>> getQuizLeaderboard() async {
    try {
      final response = await dio.get(ApiRoutes.quizLeaderboard);
      return JsonUtils.unwrapList(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Video progress ────────────────────────────────────────────────────

  @override
  Future<void> saveVideoProgress(String lessonId, Map<String, dynamic> data) async {
    try {
      await dio.post(ApiRoutes.saveVideoProgress(lessonId), data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getVideoProgress(String lessonId, String userId) async {
    try {
      final response = await dio.get(ApiRoutes.getVideoProgress(lessonId, userId));
      return JsonUtils.unwrapMap(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Live classes ──────────────────────────────────────────────────────

  @override
  Future<void> createLiveClass(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiRoutes.createLiveClass, data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> startLiveClass(String id) async {
    try {
      await dio.put(ApiRoutes.startLiveClass(id));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> endLiveClass(String id) async {
    try {
      await dio.put(ApiRoutes.endLiveClass(id));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> joinLiveClass(String id) async {
    try {
      final response = await dio.get(ApiRoutes.joinLiveClass(id));
      return JsonUtils.unwrapMap(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<LiveClassModel>> getLiveClassesByCourse(String courseId) async {
    try {
      final response = await dio.get(ApiRoutes.liveClassesByCourse(courseId));
      return JsonUtils.toList(
        JsonUtils.unwrapList(response.data),
        LiveClassModel.fromJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<LiveClassModel>> getRecordingsByCourse(String courseId) async {
    try {
      final response = await dio.get(ApiRoutes.recordingsByCourse(courseId));
      return JsonUtils.toList(
        JsonUtils.unwrapList(response.data),
        LiveClassModel.fromJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> uploadRecording(String liveClassId, File file) async {
    try {
      // Rule 11: the recording is produced by the teacher's browser and then
      // uploaded here. There is no upload size limit and progress continues in
      // the background, so this call may run for a long time.
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _fileName(file),
        ),
      });
      await dio.post(
        ApiRoutes.uploadRecording(liveClassId),
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 30),
          receiveTimeout: const Duration(minutes: 30),
        ),
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Store ─────────────────────────────────────────────────────────────

  @override
  Future<List<StoreItemModel>> getStoreItems() async {
    try {
      final response = await dio.get(ApiRoutes.storeItems);
      return JsonUtils.toList(
        JsonUtils.unwrapList(response.data),
        StoreItemModel.fromJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> addStoreItem(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiRoutes.addStoreItem, data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> uploadStoreItemPdf(String id, File pdf) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdf.path,
          filename: _fileName(pdf),
        ),
      });
      await dio.post(ApiRoutes.uploadStorePdf(id), data: formData);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteStoreItem(String id) async {
    try {
      await dio.delete(ApiRoutes.deleteStoreItem(id));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Wishlist ──────────────────────────────────────────────────────────

  @override
  Future<void> toggleWishlist(String courseId, String userId) async {
    try {
      await dio.post(ApiRoutes.toggleWishlist(courseId, userId));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<bool> checkWishlist(String courseId, String userId) async {
    try {
      final response = await dio.get(ApiRoutes.checkWishlist(courseId, userId));
      final map = JsonUtils.unwrapMap(response.data);
      return JsonUtils.toBool(
        response.data is bool ? response.data : (map['data'] ?? map['isWishlisted']),
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<CourseModel>> getMyWishlist(String userId) async {
    try {
      final response = await dio.get(ApiRoutes.wishlist(userId));
      return JsonUtils.toList(
        JsonUtils.unwrapList(response.data),
        CourseModel.fromJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Certificates ──────────────────────────────────────────────────────

  @override
  Future<void> issueCertificate(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiRoutes.issueCertificate, data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<CertificateModel>> getMyCertificates(String userId) async {
    try {
      final response = await dio.get(ApiRoutes.myCertificates(userId));
      return JsonUtils.toList(
        JsonUtils.unwrapList(response.data),
        CertificateModel.fromJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<CertificateModel>> getCourseCertificates(String courseId) async {
    try {
      final response = await dio.get(ApiRoutes.courseCertificates(courseId));
      return JsonUtils.toList(
        JsonUtils.unwrapList(response.data),
        CertificateModel.fromJson,
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Instructors ───────────────────────────────────────────────────────

  @override
  Future<List<dynamic>> getAllInstructors() async {
    try {
      final response = await dio.get(ApiRoutes.allInstructors);
      return JsonUtils.unwrapList(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getInstructorProfile(String teacherId) async {
    try {
      final response = await dio.get(ApiRoutes.instructorProfile(teacherId));
      return JsonUtils.unwrapMap(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> updateTeacherProfile(Map<String, dynamic> data) async {
    try {
      await dio.put(ApiRoutes.updateInstructorProfile, data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> uploadProfileImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _fileName(file),
        ),
      });
      await dio.post(ApiRoutes.uploadInstructorImage, data: formData);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Ratings ───────────────────────────────────────────────────────────

  @override
  Future<void> addRating(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiRoutes.addRating, data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getRatingSummary(String courseId) async {
    try {
      final response = await dio.get(ApiRoutes.ratingSummary(courseId));
      return JsonUtils.unwrapMap(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteRating(String ratingId, String userId) async {
    try {
      await dio.delete(ApiRoutes.deleteRating(ratingId, userId));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Comments ──────────────────────────────────────────────────────────

  @override
  Future<List<dynamic>> getCourseComments(
    String courseId,
    int pageNumber,
    int pageSize,
  ) async {
    try {
      final response = await dio.get(
        ApiRoutes.courseComments(courseId),
        queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
      );
      return JsonUtils.unwrapList(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> addComment(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiRoutes.addComment, data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> updateComment(String id, String content) async {
    try {
      await dio.put(ApiRoutes.updateComment(id), data: {'content': content});
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteComment(String id) async {
    try {
      await dio.delete(ApiRoutes.deleteComment(id));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  /// Extracts a filename that works on both Windows (`\`) and POSIX (`/`).
  static String _fileName(File file) {
    return file.path.split(RegExp(r'[/\\]')).last;
  }
}