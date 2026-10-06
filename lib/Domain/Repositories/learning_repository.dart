import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../Core/Error/failures.dart';
import '../Entities/ai_writing_entity.dart';
import '../Entities/exam_entity.dart';
import '../Entities/live_exam_entity.dart';
import '../Entities/notification_entity.dart';
import '../Entities/payment_entity.dart';
import '../Entities/practice_entity.dart';
import '../Entities/progress_entity.dart';
import '../Entities/refund_entity.dart';
import '../Entities/teacher_evaluation_entity.dart';

/// Domain contract for every learning surface: exams, live exams, AI writing,
/// practice files, progress, refunds, checkout and notifications.
abstract class LearningRepository {
  // ── Course exams (Manual §4.4) ─────────────────────────────────────────
  Future<Either<Failure, List<ExamEntity>>> getExamsByCourse(String courseId);
  Future<Either<Failure, ExamEntity>> createExam(Map<String, dynamic> data);
  Future<Either<Failure, Unit>> uploadExamQuestion(String examId, File file);
  Future<Either<Failure, Map<String, dynamic>>> getExamQuestion(String examId);
  Future<Either<Failure, Unit>> submitExamAnswer(String examId, File file);
  Future<Either<Failure, List<ExamSubmissionEntity>>> getExamSubmissions(String examId);
  Future<Either<Failure, Unit>> gradeExamSubmission(
    String submissionId,
    int marks,
    String? feedback,
  );

  // ── Live-class exams (Manual §4.4 / §5.2, Rule 10) ─────────────────────
  Future<Either<Failure, LiveExamEntity?>> getLiveExamForClass(String liveClassId);
  Future<Either<Failure, LiveExamEntity?>> getLiveExamManage(String liveClassId);
  Future<Either<Failure, LiveExamEntity>> saveLiveExam(
    String liveClassId,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, Unit>> publishLiveExam(String examId);
  Future<Either<Failure, Unit>> closeLiveExam(String examId);
  Future<Either<Failure, Unit>> deleteLiveExam(String examId);
  Future<Either<Failure, LiveExamEntity>> takeLiveExam(String examId);
  Future<Either<Failure, Unit>> submitLiveExam(String examId, Map<String, dynamic> answers);
  Future<Either<Failure, List<LiveExamSubmissionEntity>>> getLiveExamSubmissions(String examId);
  Future<Either<Failure, Unit>> gradeLiveExamSubmission(
    String submissionId,
    double marks,
    String? feedback,
  );

  // ── AI writing (Manual §4.4) ───────────────────────────────────────────
  Future<Either<Failure, List<AiWritingTaskEntity>>> getAiWritingByCourse(String courseId);
  Future<Either<Failure, AiWritingTaskEntity>> getAiWritingTask(String taskId);
  Future<Either<Failure, Unit>> submitAiWriting(String taskId, File handwritingPhoto);
  Future<Either<Failure, List<AiWritingSubmissionEntity>>> getAiWritingSubmissions(String taskId);

  // ── Practice & suggestions (Manual §4.3) ───────────────────────────────
  Future<Either<Failure, List<PracticeEntity>>> getPracticeByCourse(String courseId);

  // ── Progress & watch history (Manual §4.3) ─────────────────────────────
  Future<Either<Failure, List<CourseProgressEntity>>> getMyProgress();
  Future<Either<Failure, List<WatchHistoryItemEntity>>> getWatchHistory(String userId);
  Future<Either<Failure, Unit>> hideWatchHistoryItem(
    String userId,
    String contentId, {
    required bool isRecording,
  });
  Future<Either<Failure, Unit>> restoreWatchHistoryItem(
    String userId,
    String contentId, {
    required bool isRecording,
  });

  // ── Refunds (Rule 9) ───────────────────────────────────────────────────
  Future<Either<Failure, RefundEligibilityEntity>> getRefundEligibility(String courseId);
  Future<Either<Failure, RefundEntity>> requestRefund(String courseId, String reason);
  Future<Either<Failure, List<RefundEntity>>> getMyRefunds();
  Future<Either<Failure, Unit>> cancelRefund(String refundId);

  // ── Payments & discounts (Manual §4.2, Rule 4) ─────────────────────────
  Future<Either<Failure, PaymentQuoteEntity>> getPaymentQuote(
    String courseId, {
    String? couponCode,
    String? corporateCouponId,
  });
  Future<Either<Failure, List<CorporateCouponEntity>>> getCorporateCouponsForCourse(
    String courseId,
  );
  Future<Either<Failure, PaymentInitiationEntity>> initiatePayment({
    required String courseId,
    String? couponCode,
    String? corporateCouponId,
    String? phone,
  });

  // ── Free live classes (Rule 12 — public) ───────────────────────────────
  Future<Either<Failure, List<Map<String, dynamic>>>> getActiveFreeLiveClasses();
  Future<Either<Failure, Map<String, dynamic>>> joinFreeLiveClass(String id);

  // ── Notifications & announcements (Manual §4.5) ────────────────────────
  Future<Either<Failure, List<NotificationEntity>>> getMyNotifications();
  Future<Either<Failure, int>> getUnreadNotificationCount();
  Future<Either<Failure, Unit>> markNotificationRead(String id);
  Future<Either<Failure, Unit>> markAllNotificationsRead();
  Future<Either<Failure, List<AnnouncementEntity>>> getActiveAnnouncements();

  // ── Teacher evaluation (Manual §4.4) ───────────────────────────────────
  Future<Either<Failure, Unit>> submitTeacherEvaluation(
    TeacherEvaluationEntity evaluation,
  );
  Future<Either<Failure, TeacherEvaluationEntity?>> getMyTeacherEvaluation(
    String courseId,
  );

  // ── Pre-booking (Rule 3) ───────────────────────────────────────────────
  Future<Either<Failure, Unit>> createPreBooking({
    required String courseId,
    String? studentName,
    String? phone,
    String? email,
  });

  // ── Support (Manual §4.5) ──────────────────────────────────────────────
  Future<Either<Failure, Unit>> submitSupportTicket({
    required String message,
    String? subject,
  });
}