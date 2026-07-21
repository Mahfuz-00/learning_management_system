import 'dart:io';
import 'package:dio/dio.dart';
import '../Models/course_model.dart';
import '../Models/lesson_model.dart';
import '../Models/quiz_model.dart';
import '../Models/live_class_model.dart';
import '../Models/store_item_model.dart';
import '../Models/certificate_model.dart';

abstract class CourseRemoteDataSource {
  // Course Endpoints
  Future<List<CourseModel>> getAllCourses();
  Future<List<CourseModel>> getTeacherCourses();
  Future<CourseModel> getCourseById(String id);
  Future<String> createCourse(Map<String, dynamic> data);
  Future<void> updateCourse(String id, Map<String, dynamic> data);
  Future<void> deleteCourse(String id);
  Future<void> uploadThumbnail(String id, File image);

  // Lesson Endpoints
  Future<List<LessonModel>> getLessonsByCourse(String courseId);
  Future<LessonModel> getLessonById(String id);
  Future<String> createLesson(Map<String, dynamic> data);
  Future<void> updateLesson(String id, Map<String, dynamic> data);
  Future<void> deleteLesson(String id);
  Future<void> uploadLessonVideo(String id, File video);
  Future<void> setVideoUrl(String id, String url); // Documentation: SetVideoUrl
  Future<void> uploadLessonThumbnail(String id, File image);

  // Enrollment Endpoints
  Future<void> enrollInCourse(String courseId);
  Future<Map<String, dynamic>> checkEnrollmentStatus(String courseId);
  Future<List<CourseModel>> getMyEnrollments();
  Future<List<dynamic>> getEnrolledStudents(String courseId);
  Future<Map<String, dynamic>> getEnrollmentCount(String courseId);

  // Quiz Endpoints
  Future<List<QuestionModel>> getQuizQuestions(String lessonId);
  Future<void> addQuizQuestion(String lessonId, Map<String, dynamic> quizData);
  Future<void> deleteQuizQuestion(String quizId);
  Future<Map<String, dynamic>> submitQuiz(String lessonId, Map<String, dynamic> payload);
  Future<bool> hasAttemptedQuiz(String lessonId, String userId);
  Future<List<dynamic>> getQuizLeaderboard();

  // Video Progress Endpoints
  Future<void> saveVideoProgress(String lessonId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> getVideoProgress(String lessonId, String userId);
  Future<List<dynamic>> getWatchHistory(String userId);

  // Live Class Endpoints
  Future<void> createLiveClass(Map<String, dynamic> data);
  Future<void> startLiveClass(String id);
  Future<void> endLiveClass(String id);
  Future<Map<String, dynamic>> joinLiveClass(String id);
  Future<List<LiveClassModel>> getLiveClassesByCourse(String courseId);

  // Store Endpoints
  Future<List<StoreItemModel>> getStoreItems();
  Future<void> addStoreItem(Map<String, dynamic> data);
  Future<void> uploadStoreItemPdf(String id, File pdf);
  Future<void> deleteStoreItem(String id);

  // Wishlist Endpoints
  Future<void> toggleWishlist(String courseId, String userId);
  Future<bool> checkWishlist(String courseId, String userId);
  Future<List<CourseModel>> getMyWishlist(String userId);

  // Certificate Endpoints
  Future<void> issueCertificate(Map<String, dynamic> data);
  Future<List<CertificateModel>> getMyCertificates(String userId);
  Future<List<CertificateModel>> getCourseCertificates(String courseId);

  // Announcement Endpoints
  Future<List<dynamic>> getActiveAnnouncements();
  Future<void> createAnnouncement(Map<String, dynamic> data);
  Future<void> deactivateAnnouncement(String id);
  Future<void> deleteAnnouncement(String id);

  // Notification Endpoints
  Future<List<dynamic>> getMyNotifications();
  Future<Map<String, dynamic>> getUnreadNotificationCount();
  Future<void> markNotificationAsRead(String id);
  Future<void> markAllNotificationsAsRead();

  // Instructor Endpoints
  Future<List<dynamic>> getAllInstructors();
  Future<Map<String, dynamic>> getInstructorProfile(String teacherId);
  Future<void> updateTeacherProfile(Map<String, dynamic> data);
  Future<void> uploadProfileImage(File file);

  // Rating Endpoints
  Future<void> addRating(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getRatingSummary(String courseId);
  Future<void> deleteRating(String ratingId, String userId);

  // Comment Endpoints
  Future<List<dynamic>> getCourseComments(String courseId, int pageNumber, int pageSize);
  Future<void> addComment(Map<String, dynamic> data);
  Future<void> updateComment(String id, String content);
  Future<void> deleteComment(String id);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final Dio dio;

  CourseRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CourseModel>> getAllCourses() async {
    final response = await dio.get('Course/GetAll');
    final List data = response.data['data'] ?? [];
    return data.map((e) => CourseModel.fromJson(e)).toList();
  }

  @override
  Future<List<CourseModel>> getTeacherCourses() async {
    final response = await dio.get('Course/GetByTeacher');
    final List data = response.data['data'] ?? [];
    return data.map((e) => CourseModel.fromJson(e)).toList();
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    final response = await dio.get('Course/GetById/$id');
    return CourseModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<String> createCourse(Map<String, dynamic> data) async {
    final response = await dio.post('Course/Create', data: data);
    return (response.data['data'] ?? '').toString();
  }

  @override
  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    await dio.put('Course/Update/$id', data: data);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await dio.delete('Course/Delete/$id');
  }

  @override
  Future<void> uploadThumbnail(String id, File image) async {
    String fileName = image.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(image.path, filename: fileName),
    });
    await dio.post('Course/UploadThumbnail/$id', data: formData);
  }

  @override
  Future<List<LessonModel>> getLessonsByCourse(String courseId) async {
    final response = await dio.get('Lesson/GetByCourse/$courseId');
    final List data = response.data['data'] ?? [];
    return data.map((e) => LessonModel.fromJson(e)).toList();
  }

  @override
  Future<LessonModel> getLessonById(String id) async {
    final response = await dio.get('Lesson/GetById/$id');
    return LessonModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<String> createLesson(Map<String, dynamic> data) async {
    final response = await dio.post('Lesson/Create', data: data);
    return (response.data['data'] ?? '').toString();
  }

  @override
  Future<void> updateLesson(String id, Map<String, dynamic> data) async {
    await dio.put('Lesson/Update/$id', data: data);
  }

  @override
  Future<void> deleteLesson(String id) async {
    await dio.delete('Lesson/Delete/$id');
  }

  @override
  Future<void> uploadLessonVideo(String id, File video) async {
    String fileName = video.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(video.path, filename: fileName),
    });
    await dio.post('Lesson/UploadVideo/$id', data: formData);
  }

  @override
  Future<void> setVideoUrl(String id, String url) async {
    await dio.post('Lesson/SetVideoUrl/$id', data: {'videoUrl': url});
  }

  @override
  Future<void> uploadLessonThumbnail(String id, File image) async {
    String fileName = image.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(image.path, filename: fileName),
    });
    await dio.post('Lesson/UploadThumbnail/$id', data: formData);
  }

  @override
  Future<void> enrollInCourse(String courseId) async {
    await dio.post('Enrollment/create', data: {'courseId': courseId});
  }

  @override
  Future<Map<String, dynamic>> checkEnrollmentStatus(String courseId) async {
    final response = await dio.get('Enrollment/by-course/$courseId');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<CourseModel>> getMyEnrollments() async {
    final response = await dio.get('Enrollment/my-enrollments');
    final List data = response.data['data'] ?? [];
    return data.map((e) => CourseModel.fromJson(e)).toList();
  }

  @override
  Future<List<dynamic>> getEnrolledStudents(String courseId) async {
    final response = await dio.get('Enrollment/students/$courseId');
    return response.data['data'] ?? [];
  }

  @override
  Future<Map<String, dynamic>> getEnrollmentCount(String courseId) async {
    final response = await dio.get('Enrollment/count/$courseId');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<QuestionModel>> getQuizQuestions(String lessonId) async {
    final response = await dio.get('quiz/getbylesson/$lessonId');
    final List data = response.data['data'] ?? [];
    return data.map((e) => QuestionModel.fromJson(e)).toList();
  }

  @override
  Future<void> addQuizQuestion(String lessonId, Map<String, dynamic> quizData) async {
    await dio.post('quiz/add/$lessonId', data: quizData);
  }

  @override
  Future<void> deleteQuizQuestion(String quizId) async {
    await dio.delete('quiz/delete/$quizId');
  }

  @override
  Future<Map<String, dynamic>> submitQuiz(String lessonId, Map<String, dynamic> payload) async {
    final response = await dio.post('quiz/submit/$lessonId', data: payload);
    return response.data['data'] ?? {};
  }

  @override
  Future<bool> hasAttemptedQuiz(String lessonId, String userId) async {
    final response = await dio.get('quiz/hasattempted/$lessonId/$userId');
    return response.data['data'] ?? false;
  }

  @override
  Future<List<dynamic>> getQuizLeaderboard() async {
    final response = await dio.get('quiz/leaderboard');
    return response.data['data'] ?? [];
  }

  @override
  Future<void> saveVideoProgress(String lessonId, Map<String, dynamic> data) async {
    await dio.post('VideoProgress/save/$lessonId', data: data);
  }

  @override
  Future<Map<String, dynamic>> getVideoProgress(String lessonId, String userId) async {
    final response = await dio.get('VideoProgress/get/$lessonId/$userId');
    return response.data['data'] ?? {};
  }

  @override
  Future<List<dynamic>> getWatchHistory(String userId) async {
    final response = await dio.get('VideoProgress/history/$userId');
    return response.data['data'] ?? [];
  }

  @override
  Future<void> createLiveClass(Map<String, dynamic> data) async {
    await dio.post('LiveClass/create', data: data);
  }

  @override
  Future<void> startLiveClass(String id) async {
    await dio.put('LiveClass/start/$id');
  }

  @override
  Future<void> endLiveClass(String id) async {
    await dio.put('LiveClass/end/$id');
  }

  @override
  Future<Map<String, dynamic>> joinLiveClass(String id) async {
    final response = await dio.get('LiveClass/join/$id');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<LiveClassModel>> getLiveClassesByCourse(String courseId) async {
    final response = await dio.get('LiveClass/course/$courseId');
    final List data = response.data['data'] ?? [];
    return data.map((e) => LiveClassModel.fromJson(e)).toList();
  }

  @override
  Future<List<StoreItemModel>> getStoreItems() async {
    final response = await dio.get('Store/items');
    final List data = response.data['data'] ?? [];
    return data.map((e) => StoreItemModel.fromJson(e)).toList();
  }

  @override
  Future<void> addStoreItem(Map<String, dynamic> data) async {
    await dio.post('Store/add', data: data);
  }

  @override
  Future<void> uploadStoreItemPdf(String id, File pdf) async {
    String fileName = pdf.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(pdf.path, filename: fileName),
    });
    await dio.post('Store/upload-pdf/$id', data: formData);
  }

  @override
  Future<void> deleteStoreItem(String id) async {
    await dio.delete('Store/delete/$id');
  }

  @override
  Future<void> toggleWishlist(String courseId, String userId) async {
    await dio.post('Wishlist/toggle/$courseId/$userId');
  }

  @override
  Future<bool> checkWishlist(String courseId, String userId) async {
    final response = await dio.get('Wishlist/check/$courseId/$userId');
    return response.data['data'] ?? false;
  }

  @override
  Future<List<CourseModel>> getMyWishlist(String userId) async {
    final response = await dio.get('Wishlist/$userId');
    final List data = response.data['data'] ?? [];
    return data.map((e) => CourseModel.fromJson(e)).toList();
  }

  @override
  Future<void> issueCertificate(Map<String, dynamic> data) async {
    await dio.post('Certificate/issue', data: data);
  }

  @override
  Future<List<CertificateModel>> getMyCertificates(String userId) async {
    final response = await dio.get('Certificate/my/$userId');
    final List data = response.data['data'] ?? [];
    return data.map((e) => CertificateModel.fromJson(e)).toList();
  }

  @override
  Future<List<CertificateModel>> getCourseCertificates(String courseId) async {
    final response = await dio.get('Certificate/course/$courseId');
    final List data = response.data['data'] ?? [];
    return data.map((e) => CertificateModel.fromJson(e)).toList();
  }

  @override
  Future<List<dynamic>> getActiveAnnouncements() async {
    final response = await dio.get('Announcement/active');
    return response.data['data'] ?? [];
  }

  @override
  Future<void> createAnnouncement(Map<String, dynamic> data) async {
    await dio.post('Announcement/create', data: data);
  }

  @override
  Future<void> deactivateAnnouncement(String id) async {
    await dio.put('Announcement/deactivate/$id');
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    await dio.delete('Announcement/delete/$id');
  }

  @override
  Future<List<dynamic>> getMyNotifications() async {
    final response = await dio.get('Notification/my');
    return response.data['data'] ?? [];
  }

  @override
  Future<Map<String, dynamic>> getUnreadNotificationCount() async {
    final response = await dio.get('Notification/unread-count');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    await dio.put('Notification/read/$id');
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    await dio.put('Notification/read-all');
  }

  @override
  Future<List<dynamic>> getAllInstructors() async {
    final response = await dio.get('Instructor/all');
    return response.data['data'] ?? [];
  }

  @override
  Future<Map<String, dynamic>> getInstructorProfile(String teacherId) async {
    final response = await dio.get('Instructor/$teacherId');
    return response.data['data'] ?? {};
  }

  @override
  Future<void> updateTeacherProfile(Map<String, dynamic> data) async {
    await dio.put('Instructor/update-profile', data: data);
  }

  @override
  Future<void> uploadProfileImage(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    await dio.post('Instructor/upload-profile-image', data: formData);
  }

  @override
  Future<void> addRating(Map<String, dynamic> data) async {
    await dio.post('CourseRating/add', data: data);
  }

  @override
  Future<Map<String, dynamic>> getRatingSummary(String courseId) async {
    final response = await dio.get('CourseRating/summary/$courseId');
    return response.data['data'] ?? {};
  }

  @override
  Future<void> deleteRating(String ratingId, String userId) async {
    await dio.delete('CourseRating/$ratingId/$userId');
  }

  @override
  Future<List<dynamic>> getCourseComments(String courseId, int pageNumber, int pageSize) async {
    final response = await dio.get('CourseComment/course/$courseId', queryParameters: {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    });
    return response.data['data'] ?? [];
  }

  @override
  Future<void> addComment(Map<String, dynamic> data) async {
    await dio.post('CourseComment/add', data: data);
  }

  @override
  Future<void> updateComment(String id, String content) async {
    await dio.put('CourseComment/update/$id', data: {'content': content});
  }

  @override
  Future<void> deleteComment(String id) async {
    await dio.delete('CourseComment/delete/$id');
  }
}
