import 'package:dio/dio.dart';
import '../Models/course_model.dart';
import '../Models/lesson_model.dart';
import '../Models/quiz_model.dart';
import 'dart:developer';
import 'dart:io';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getAllCourses();
  Future<CourseModel> getCourseById(String id);
  Future<List<CourseModel>> getMyCourses();
  Future<void> enrollInCourse(String courseId);
  Future<List<LessonModel>> getLessonsByCourse(String courseId);
  Future<bool> checkEnrollmentStatus(String courseId);
  Future<void> saveVideoProgress(String lessonId, double progress);
  Future<QuizModel> getQuizByLesson(String lessonId);
  Future<void> submitQuizAttempt(String quizId, Map<String, dynamic> answers);
  
  // Teacher Actions
  Future<CourseModel> createCourse(Map<String, dynamic> courseData);
  Future<void> uploadThumbnail(String courseId, File thumbnail);
  Future<LessonModel> createLesson(Map<String, dynamic> lessonData);
  Future<void> uploadLessonVideo(String lessonId, File video);
  Future<void> setLessonYoutubeUrl(String lessonId, String youtubeUrl);
  Future<void> createQuiz(Map<String, dynamic> quizData);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final Dio dio;

  CourseRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CourseModel>> getAllCourses() async {
    log('API Request: Get all courses');
    try {
      final response = await dio.get('/course/getall');
      log('API Response: Get all courses success');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => CourseModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load courses');
      }
    } on DioException catch (e) {
      log('API Error: Get all courses failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    log('API Request: Get course by id: $id');
    try {
      final response = await dio.get('/course/getbyid/$id');
      log('API Response: Get course success');
      if (response.statusCode == 200) {
        return CourseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load course details');
      }
    } on DioException catch (e) {
      log('API Error: Get course failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<List<CourseModel>> getMyCourses() async {
    log('API Request: Get my courses');
    try {
      final response = await dio.get('/enrollment/mycourses');
      log('API Response: Get my courses success');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => CourseModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load your courses');
      }
    } on DioException catch (e) {
      log('API Error: Get my courses failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<void> enrollInCourse(String courseId) async {
    log('API Request: Enroll in course: $courseId');
    try {
      final response = await dio.post('/enrollment/enroll', data: {
        'courseId': courseId,
      });
      log('API Response: Enroll success');
    } on DioException catch (e) {
      log('API Error: Enroll failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<List<LessonModel>> getLessonsByCourse(String courseId) async {
    log('API Request: Get lessons for course: $courseId');
    try {
      final response = await dio.get('/lesson/getbycourse/$courseId');
      log('API Response: Get lessons success');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => LessonModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load lessons');
      }
    } on DioException catch (e) {
      log('API Error: Get lessons failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<bool> checkEnrollmentStatus(String courseId) async {
    log('API Request: Check enrollment status for course: $courseId');
    try {
      final response = await dio.get('/enrollment/status/$courseId');
      log('API Response: Enrollment status: ${response.data}');
      return response.data == true || response.data['isEnrolled'] == true;
    } on DioException catch (e) {
      log('API Error: Check enrollment status failed: ${e.response?.data}');
      return false;
    }
  }

  @override
  Future<void> saveVideoProgress(String lessonId, double progress) async {
    log('API Request: Save video progress for lesson: $lessonId, progress: $progress');
    try {
      await dio.post('/videoprogress/save', data: {
        'lessonId': lessonId,
        'progress': progress,
      });
      log('API Response: Save video progress success');
    } on DioException catch (e) {
      log('API Error: Save video progress failed: ${e.response?.data}');
    }
  }

  @override
  Future<QuizModel> getQuizByLesson(String lessonId) async {
    log('API Request: Get quiz for lesson: $lessonId');
    try {
      final response = await dio.get('/quiz/getbylesson/$lessonId');
      log('API Response: Get quiz success');
      if (response.statusCode == 200) {
        return QuizModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load quiz');
      }
    } on DioException catch (e) {
      log('API Error: Get quiz failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<void> submitQuizAttempt(String quizId, Map<String, dynamic> answers) async {
    log('API Request: Submit quiz attempt for quiz: $quizId');
    try {
      await dio.post('/quiz/attempt', data: {
        'quizId': quizId,
        'answers': answers,
      });
      log('API Response: Submit quiz attempt success');
    } on DioException catch (e) {
      log('API Error: Submit quiz attempt failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<CourseModel> createCourse(Map<String, dynamic> courseData) async {
    log('API Request: Create course: $courseData');
    try {
      final response = await dio.post('/course/create', data: courseData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log('API Response: Create course success');
        return CourseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create course');
      }
    } on DioException catch (e) {
      log('API Error: Create course failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<void> uploadThumbnail(String courseId, File thumbnail) async {
    log('API Request: Upload thumbnail for course: $courseId');
    try {
      String fileName = thumbnail.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(thumbnail.path, filename: fileName),
      });
      await dio.post('/course/uploadthumbnail/$courseId', data: formData);
      log('API Response: Upload thumbnail success');
    } on DioException catch (e) {
      log('API Error: Upload thumbnail failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<LessonModel> createLesson(Map<String, dynamic> lessonData) async {
    log('API Request: Create lesson: $lessonData');
    try {
      final response = await dio.post('/lesson/create', data: lessonData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log('API Response: Create lesson success');
        return LessonModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create lesson');
      }
    } on DioException catch (e) {
      log('API Error: Create lesson failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<void> uploadLessonVideo(String lessonId, File video) async {
    log('API Request: Upload video for lesson: $lessonId');
    try {
      String fileName = video.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(video.path, filename: fileName),
      });
      await dio.post('/lesson/uploadvideo/$lessonId', data: formData);
      log('API Response: Upload video success');
    } on DioException catch (e) {
      log('API Error: Upload video failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<void> setLessonYoutubeUrl(String lessonId, String youtubeUrl) async {
    log('API Request: Set YouTube URL for lesson: $lessonId');
    try {
      await dio.post('/lesson/setvideourl/$lessonId', data: {'youtubeUrl': youtubeUrl});
      log('API Response: Set YouTube URL success');
    } on DioException catch (e) {
      log('API Error: Set YouTube URL failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<void> createQuiz(Map<String, dynamic> quizData) async {
    log('API Request: Create quiz: $quizData');
    try {
      await dio.post('/quiz/create', data: quizData);
      log('API Response: Create quiz success');
    } on DioException catch (e) {
      log('API Error: Create quiz failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }
}
