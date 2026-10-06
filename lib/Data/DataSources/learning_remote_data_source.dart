import 'dart:io';
import 'package:dio/dio.dart';
import '../../Core/Constants/api_routes.dart';
import '../../Core/Error/exceptions.dart';
import '../Models/ai_writing_model.dart';
import '../Models/exam_model.dart';
import '../Models/json_utils.dart';
import '../Models/live_exam_model.dart';
import '../Models/notification_model.dart';
import '../Models/payment_model.dart';
import '../Models/practice_model.dart';
import '../Models/progress_model.dart';
import '../Models/refund_model.dart';
import '../Models/teacher_evaluation_model.dart';

/// Remote contract covering every learning-surface endpoint a student or
/// teacher needs that is not already handled by the course/auth data sources.
///
/// Grouped into one interface because they share the same lifecycle (they all
/// hang off an enrolled course) and one Dio instance. Splitting them further
/// would add files without adding clarity.
abstract class LearningRemoteDataSource {
  // ── Course exams (Manual §4.4) ────────────────────────────────────────
  Future<List<ExamModel>> getExamsByCourse(String courseId);
  Future<ExamModel> createExam(Map<String, dynamic> data);
  Future<void> uploadExamQuestion(String examId, File file);
  Future<Map<String, dynamic>> getExamQuestion(String examId);
  Future<void> submitExamAnswer(String examId, File file);
  Future<List<ExamSubmissionModel>> getExamSubmissions(String examId);
  Future<void> gradeExamSubmission(
    String submissionId,
    int marks,
    String? feedback,
  );

  // ── Live-class exams (Manual §4.4 / §5.2, Rule 10) ────────────────────
  Future<LiveExamModel?> getLiveExamForClass(String liveClassId);
  Future<LiveExamModel?> getLiveExamManage(String liveClassId);
  Future<LiveExamModel> saveLiveExam(
    String liveClassId,
    Map<String, dynamic> data,
  );
  Future<void> publishLiveExam(String examId);
  Future<void> closeLiveExam(String examId);
  Future<void> deleteLiveExam(String examId);
  Future<LiveExamModel> takeLiveExam(String examId);
  Future<void> submitLiveExam(String examId, Map<String, dynamic> answers);
  Future<List<LiveExamSubmissionModel>> getLiveExamSubmissions(String examId);
  Future<void> gradeLiveExamSubmission(
    String submissionId,
    double marks,
    String? feedback,
  );

  // ── AI writing (Manual §4.4) ──────────────────────────────────────────
  Future<List<AiWritingTaskModel>> getAiWritingByCourse(String courseId);
  Future<AiWritingTaskModel> getAiWritingTask(String taskId);
  Future<void> submitAiWriting(String taskId, File handwritingPhoto);
  Future<List<AiWritingSubmissionModel>> getAiWritingSubmissions(String taskId);

  // ── Practice & suggestions (Manual §4.3) ──────────────────────────────
  Future<List<PracticeModel>> getPracticeByCourse(String courseId);

  // ── Progress & watch history (Manual §4.3) ────────────────────────────
  Future<List<CourseProgressModel>> getMyProgress();
  Future<List<WatchHistoryItemModel>> getWatchHistory(String userId);
  Future<void> hideWatchHistoryItem(String userId, String contentId,
      {required bool isRecording});
  Future<void> restoreWatchHistoryItem(String userId, String contentId,
      {required bool isRecording});

  // ── Refunds (Rule 9) ──────────────────────────────────────────────────
  Future<RefundEligibilityModel> getRefundEligibility(String courseId);
  Future<RefundModel> requestRefund(String courseId, String reason);
  Future<List<RefundModel>> getMyRefunds();
  Future<void> cancelRefund(String refundId);

  // ── Payments & discounts (Manual §4.2, Rule 4) ────────────────────────
  Future<PaymentQuoteModel> getPaymentQuote(
    String courseId, {
    String? couponCode,
    String? corporateCouponId,
  });
  Future<List<CorporateCouponModel>> getCorporateCouponsForCourse(
    String courseId,
  );
  Future<PaymentInitiationModel> initiatePayment({
    required String courseId,
    String? couponCode,
    String? corporateCouponId,
    String? phone,
  });

  // ── Free live classes (Rule 12 — public) ──────────────────────────────
  Future<List<Map<String, dynamic>>> getActiveFreeLiveClasses();
  Future<Map<String, dynamic>> joinFreeLiveClass(String id);

  // ── Notifications & announcements (Manual §4.5) ───────────────────────
  Future<List<NotificationModel>> getMyNotifications();
  Future<int> getUnreadNotificationCount();
  Future<void> markNotificationRead(String id);
  Future<void> markAllNotificationsRead();
  Future<List<AnnouncementModel>> getActiveAnnouncements();

  // ── Teacher evaluation (Manual §4.4) ──────────────────────────────────
  Future<void> submitTeacherEvaluation(Map<String, dynamic> data);
  Future<TeacherEvaluationModel?> getMyTeacherEvaluation(String courseId);

  // ── Pre-booking (Rule 3) ──────────────────────────────────────────────
  Future<void> createPreBooking(Map<String, dynamic> data);

  // ── Support (Manual §4.5) ─────────────────────────────────────────────
  Future<void> submitSupportTicket(Map<String, dynamic> data);
}

/// Dio-backed implementation of [LearningRemoteDataSource].
class LearningRemoteDataSourceImpl implements LearningRemoteDataSource {
  final Dio dio;

  LearningRemoteDataSourceImpl({required this.dio});

  // ── Course exams ──────────────────────────────────────────────────────

  @override
  Future<List<ExamModel>> getExamsByCourse(String courseId) async {
    try {
      final response = await dio.get(ApiRoutes.examsByCourse(courseId));
      return JsonUtils.toList(response.data is Map ? response.data['data'] : response.data,
          ExamModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<ExamModel> createExam(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(ApiRoutes.createExam, data: data);
      return ExamModel.fromJson(JsonUtils.unwrapMap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> uploadExamQuestion(String examId, File file) async {
    try {
      // Uploading the question file is what OPENS the exam for students.
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _fileName(file),
        ),
      });
      await dio.post(ApiRoutes.uploadExamQuestion(examId), data: formData);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getExamQuestion(String examId) async {
    try {
      final response = await dio.get(ApiRoutes.examQuestion(examId));
      return JsonUtils.unwrapMap(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> submitExamAnswer(String examId, File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _fileName(file),
        ),
      });
      await dio.post(ApiRoutes.submitExam(examId), data: formData);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<ExamSubmissionModel>> getExamSubmissions(String examId) async {
    try {
      final response = await dio.get(ApiRoutes.examSubmissions(examId));
      final raw = response.data is Map ? response.data['data'] : response.data;
      return JsonUtils.toList(raw, ExamSubmissionModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> gradeExamSubmission(
    String submissionId,
    int marks,
    String? feedback,
  ) async {
    try {
      await dio.put(
        ApiRoutes.gradeExam(submissionId),
        data: {'marks': marks, if (feedback != null) 'feedback': feedback},
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Live-class exams ──────────────────────────────────────────────────

  @override
  Future<LiveExamModel?> getLiveExamForClass(String liveClassId) async {
    try {
      final response = await dio.get(ApiRoutes.liveExamByLiveClass(liveClassId));
      final map = JsonUtils.unwrapMap(response.data);
      if (map.isEmpty) return null;
      return LiveExamModel.fromJson(map);
    } on DioException catch (e) {
      // A 404 simply means no exam has been built for this class yet.
      if (e.response?.statusCode == 404) return null;
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<LiveExamModel?> getLiveExamManage(String liveClassId) async {
    try {
      final response = await dio.get(ApiRoutes.liveExamManage(liveClassId));
      final map = JsonUtils.unwrapMap(response.data);
      if (map.isEmpty) return null;
      return LiveExamModel.fromJson(map);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<LiveExamModel> saveLiveExam(
    String liveClassId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post(
        ApiRoutes.liveExamSave(liveClassId),
        data: data,
      );
      return LiveExamModel.fromJson(JsonUtils.unwrapMap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> publishLiveExam(String examId) async {
    try {
      await dio.post(ApiRoutes.liveExamPublish(examId));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> closeLiveExam(String examId) async {
    try {
      await dio.post(ApiRoutes.liveExamClose(examId));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteLiveExam(String examId) async {
    try {
      await dio.delete(ApiRoutes.deleteLiveExam(examId));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<LiveExamModel> takeLiveExam(String examId) async {
    try {
      final response = await dio.get(ApiRoutes.takeLiveExam(examId));
      return LiveExamModel.fromJson(JsonUtils.unwrapMap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> submitLiveExam(
    String examId,
    Map<String, dynamic> answers,
  ) async {
    try {
      await dio.post(ApiRoutes.submitLiveExam(examId), data: answers);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<LiveExamSubmissionModel>> getLiveExamSubmissions(
    String examId,
  ) async {
    try {
      final response = await dio.get(ApiRoutes.liveExamSubmissions(examId));
      final raw = response.data is Map ? response.data['data'] : response.data;
      return JsonUtils.toList(raw, LiveExamSubmissionModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> gradeLiveExamSubmission(
    String submissionId,
    double marks,
    String? feedback,
  ) async {
    try {
      await dio.put(
        ApiRoutes.gradeLiveExam(submissionId),
        data: {
          'marks': [
            {'finalMarks': marks},
          ],
          if (feedback != null) 'feedback': feedback,
        },
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── AI writing ────────────────────────────────────────────────────────

  @override
  Future<List<AiWritingTaskModel>> getAiWritingByCourse(String courseId) async {
    try {
      final response = await dio.get(ApiRoutes.aiWritingByCourse(courseId));
      final raw = response.data is Map ? response.data['data'] : response.data;
      return JsonUtils.toList(raw, AiWritingTaskModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<AiWritingTaskModel> getAiWritingTask(String taskId) async {
    try {
      final response = await dio.get(ApiRoutes.aiWritingTask(taskId));
      return AiWritingTaskModel.fromJson(JsonUtils.unwrapMap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> submitAiWriting(String taskId, File handwritingPhoto) async {
    try {
      final formData = FormData.fromMap({
        'taskId': taskId,
        'file': await MultipartFile.fromFile(
          handwritingPhoto.path,
          filename: _fileName(handwritingPhoto),
        ),
      });
      await dio.post(ApiRoutes.submitAiWriting, data: formData);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<AiWritingSubmissionModel>> getAiWritingSubmissions(
    String taskId,
  ) async {
    try {
      final response = await dio.get(ApiRoutes.aiWritingSubmissions(taskId));
      final raw = response.data is Map ? response.data['data'] : response.data;
      return JsonUtils.toList(raw, AiWritingSubmissionModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Practice & suggestions ────────────────────────────────────────────

  @override
  Future<List<PracticeModel>> getPracticeByCourse(String courseId) async {
    try {
      final response = await dio.get(ApiRoutes.practiceByCourse(courseId));
      final raw = response.data is Map ? response.data['data'] : response.data;
      return JsonUtils.toList(raw, PracticeModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Progress & watch history ──────────────────────────────────────────

  @override
  Future<List<CourseProgressModel>> getMyProgress() async {
    try {
      final response = await dio.get(ApiRoutes.myProgress);
      final raw = response.data is Map ? response.data['data'] : response.data;
      return JsonUtils.toList(raw, CourseProgressModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<WatchHistoryItemModel>> getWatchHistory(String userId) async {
    try {
      final response = await dio.get(ApiRoutes.watchHistory(userId));
      final raw = response.data is Map ? response.data['data'] : response.data;
      return JsonUtils.toList(raw, WatchHistoryItemModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> hideWatchHistoryItem(
    String userId,
    String contentId, {
    required bool isRecording,
  }) async {
    try {
      // Manual §4.3: "Removing an item only hides it — it does not delete the
      // progress." Hence a DELETE on the history row, not on the progress.
      final path = isRecording
          ? ApiRoutes.deleteRecordingHistory(userId, contentId)
          : ApiRoutes.watchHistoryItem(userId, contentId);
      await dio.delete(path);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> restoreWatchHistoryItem(
    String userId,
    String contentId, {
    required bool isRecording,
  }) async {
    try {
      final path = isRecording
          ? ApiRoutes.restoreRecordingHistory(userId, contentId)
          : ApiRoutes.restoreWatchHistoryItem(userId, contentId);
      await dio.post(path);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Refunds ───────────────────────────────────────────────────────────

  @override
  Future<RefundEligibilityModel> getRefundEligibility(String courseId) async {
    try {
      final response = await dio.get(ApiRoutes.refundEligibility(courseId));
      return RefundEligibilityModel.fromJson(JsonUtils.unwrapMap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<RefundModel> requestRefund(String courseId, String reason) async {
    try {
      final response = await dio.post(
        ApiRoutes.requestRefund,
        data: {'courseId': courseId, 'reason': reason},
      );
      return RefundModel.fromJson(JsonUtils.unwrapMap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<RefundModel>> getMyRefunds() async {
    try {
      final response = await dio.get(ApiRoutes.myRefunds);
      final raw = response.data is Map ? response.data['data'] : response.data;
      return JsonUtils.toList(raw, RefundModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> cancelRefund(String refundId) async {
    try {
      await dio.post(ApiRoutes.cancelRefund(refundId));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Payments & discounts ──────────────────────────────────────────────

  @override
  Future<PaymentQuoteModel> getPaymentQuote(
    String courseId, {
    String? couponCode,
    String? corporateCouponId,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.paymentQuote,
        data: {
          'courseId': courseId,
          if (couponCode != null && couponCode.isNotEmpty)
            'couponCode': couponCode,
          if (corporateCouponId != null && corporateCouponId.isNotEmpty)
            'corporateCouponId': corporateCouponId,
        },
      );
      return PaymentQuoteModel.fromJson(JsonUtils.unwrapMap(response.data));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<CorporateCouponModel>> getCorporateCouponsForCourse(
    String courseId,
  ) async {
    try {
      final response = await dio.get(ApiRoutes.corporateCouponsForCourse(courseId));
      final raw = response.data is Map ? response.data['data'] : response.data;
      return JsonUtils.toList(raw, CorporateCouponModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<PaymentInitiationModel> initiatePayment({
    required String courseId,
    String? couponCode,
    String? corporateCouponId,
    String? phone,
  }) async {
    try {
      final response = await dio.post(
        ApiRoutes.initiatePayment,
        data: {
          'courseId': courseId,
          if (couponCode != null && couponCode.isNotEmpty)
            'couponCode': couponCode,
          if (corporateCouponId != null && corporateCouponId.isNotEmpty)
            'corporateCouponId': corporateCouponId,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      return PaymentInitiationModel.fromJson(
        JsonUtils.unwrapMap(response.data),
      );
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Free live classes (Rule 12 — no auth) ─────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getActiveFreeLiveClasses() async {
    try {
      final response = await dio.get(ApiRoutes.freeLiveActive);
      final raw = JsonUtils.unwrapList(response.data);
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> joinFreeLiveClass(String id) async {
    try {
      final response = await dio.get(ApiRoutes.freeLiveJoin(id));
      return JsonUtils.unwrapMap(response.data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Notifications & announcements ─────────────────────────────────────

  @override
  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final response = await dio.get(ApiRoutes.myNotifications);
      final raw = JsonUtils.unwrapList(response.data);
      return JsonUtils.toList(raw, NotificationModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await dio.get(ApiRoutes.unreadNotificationCount);
      final map = JsonUtils.unwrapMap(response.data);
      // The count may be a bare integer, or wrapped in `count` / `unreadCount`.
      if (response.data is num) return (response.data as num).toInt();
      return JsonUtils.toInt(map['count'] ?? map['unreadCount'] ?? map['data']);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> markNotificationRead(String id) async {
    try {
      await dio.put(ApiRoutes.readNotification(id));
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<void> markAllNotificationsRead() async {
    try {
      await dio.put(ApiRoutes.readAllNotifications);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<List<AnnouncementModel>> getActiveAnnouncements() async {
    try {
      final response = await dio.get(ApiRoutes.activeAnnouncements);
      final raw = JsonUtils.unwrapList(response.data);
      return JsonUtils.toList(raw, AnnouncementModel.fromJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Teacher evaluation ────────────────────────────────────────────────

  @override
  Future<void> submitTeacherEvaluation(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiRoutes.submitTeacherEvaluation, data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  @override
  Future<TeacherEvaluationModel?> getMyTeacherEvaluation(
    String courseId,
  ) async {
    try {
      final response = await dio.get(ApiRoutes.myTeacherEvaluation(courseId));
      final map = JsonUtils.unwrapMap(response.data);
      if (map.isEmpty) return null;
      return TeacherEvaluationModel.fromJson(map);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw DioErrorMapper.map(e);
    }
  }

  // ── Pre-booking ───────────────────────────────────────────────────────

  @override
  Future<void> createPreBooking(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiRoutes.preBooking, data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  // ── Support ───────────────────────────────────────────────────────────

  @override
  Future<void> submitSupportTicket(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiRoutes.supportTicket, data: data);
    } on DioException catch (e) {
      throw DioErrorMapper.map(e);
    }
  }

  /// Extracts a filename that works on both Windows (`\`) and POSIX (`/`).
  static String _fileName(File file) {
    return file.path.split(RegExp(r'[/\\]')).last;
  }
}