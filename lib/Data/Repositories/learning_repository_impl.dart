import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../Core/Error/exceptions.dart';
import '../../Core/Error/failures.dart';
import '../../Domain/Entities/ai_writing_entity.dart';
import '../../Domain/Entities/exam_entity.dart';
import '../../Domain/Entities/live_exam_entity.dart';
import '../../Domain/Entities/notification_entity.dart';
import '../../Domain/Entities/payment_entity.dart';
import '../../Domain/Entities/practice_entity.dart';
import '../../Domain/Entities/progress_entity.dart';
import '../../Domain/Entities/refund_entity.dart';
import '../../Domain/Entities/teacher_evaluation_entity.dart';
import '../../Domain/Repositories/learning_repository.dart';
import '../DataSources/learning_remote_data_source.dart';

/// Data-layer implementation of [LearningRepository].
///
/// Each method is a thin try/catch wrapper: call the data source, return
/// `Right`, or translate the exception into a domain [Failure] via [_map].
class LearningRepositoryImpl implements LearningRepository {
  final LearningRemoteDataSource remoteDataSource;

  LearningRepositoryImpl({required this.remoteDataSource});

  // ── Course exams ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ExamEntity>>> getExamsByCourse(String courseId) async {
    try {
      final exams = await remoteDataSource.getExamsByCourse(courseId);
      return Right(exams);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, ExamEntity>> createExam(Map<String, dynamic> data) async {
    try {
      return Right(await remoteDataSource.createExam(data));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> uploadExamQuestion(String examId, File file) async {
    try {
      await remoteDataSource.uploadExamQuestion(examId, file);
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getExamQuestion(String examId) async {
    try {
      return Right(await remoteDataSource.getExamQuestion(examId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitExamAnswer(String examId, File file) async {
    try {
      await remoteDataSource.submitExamAnswer(examId, file);
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<ExamSubmissionEntity>>> getExamSubmissions(
    String examId,
  ) async {
    try {
      return Right(await remoteDataSource.getExamSubmissions(examId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> gradeExamSubmission(
    String submissionId,
    int marks,
    String? feedback,
  ) async {
    try {
      await remoteDataSource.gradeExamSubmission(submissionId, marks, feedback);
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  // ── Live-class exams ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, LiveExamEntity?>> getLiveExamForClass(
    String liveClassId,
  ) async {
    try {
      return Right(await remoteDataSource.getLiveExamForClass(liveClassId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, LiveExamEntity?>> getLiveExamManage(
    String liveClassId,
  ) async {
    try {
      return Right(await remoteDataSource.getLiveExamManage(liveClassId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, LiveExamEntity>> saveLiveExam(
    String liveClassId,
    Map<String, dynamic> data,
  ) async {
    try {
      return Right(await remoteDataSource.saveLiveExam(liveClassId, data));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> publishLiveExam(String examId) async {
    try {
      await remoteDataSource.publishLiveExam(examId);
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> closeLiveExam(String examId) async {
    try {
      await remoteDataSource.closeLiveExam(examId);
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteLiveExam(String examId) async {
    try {
      await remoteDataSource.deleteLiveExam(examId);
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, LiveExamEntity>> takeLiveExam(String examId) async {
    try {
      return Right(await remoteDataSource.takeLiveExam(examId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitLiveExam(
    String examId,
    Map<String, dynamic> answers,
  ) async {
    try {
      await remoteDataSource.submitLiveExam(examId, answers);
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<LiveExamSubmissionEntity>>> getLiveExamSubmissions(
    String examId,
  ) async {
    try {
      return Right(await remoteDataSource.getLiveExamSubmissions(examId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> gradeLiveExamSubmission(
    String submissionId,
    double marks,
    String? feedback,
  ) async {
    try {
      await remoteDataSource.gradeLiveExamSubmission(submissionId, marks, feedback);
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  // ── AI writing ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<AiWritingTaskEntity>>> getAiWritingByCourse(
    String courseId,
  ) async {
    try {
      return Right(await remoteDataSource.getAiWritingByCourse(courseId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, AiWritingTaskEntity>> getAiWritingTask(String taskId) async {
    try {
      return Right(await remoteDataSource.getAiWritingTask(taskId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitAiWriting(
    String taskId,
    File handwritingPhoto,
  ) async {
    try {
      await remoteDataSource.submitAiWriting(taskId, handwritingPhoto);
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<AiWritingSubmissionEntity>>> getAiWritingSubmissions(
    String taskId,
  ) async {
    try {
      return Right(await remoteDataSource.getAiWritingSubmissions(taskId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  // ── Practice ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<PracticeEntity>>> getPracticeByCourse(
    String courseId,
  ) async {
    try {
      return Right(await remoteDataSource.getPracticeByCourse(courseId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  // ── Progress & history ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<CourseProgressEntity>>> getMyProgress() async {
    try {
      return Right(await remoteDataSource.getMyProgress());
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<WatchHistoryItemEntity>>> getWatchHistory(
    String userId,
  ) async {
    try {
      return Right(await remoteDataSource.getWatchHistory(userId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> hideWatchHistoryItem(
    String userId,
    String contentId, {
    required bool isRecording,
  }) async {
    try {
      await remoteDataSource.hideWatchHistoryItem(
        userId,
        contentId,
        isRecording: isRecording,
      );
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> restoreWatchHistoryItem(
    String userId,
    String contentId, {
    required bool isRecording,
  }) async {
    try {
      await remoteDataSource.restoreWatchHistoryItem(
        userId,
        contentId,
        isRecording: isRecording,
      );
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  // ── Refunds ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, RefundEligibilityEntity>> getRefundEligibility(
    String courseId,
  ) async {
    try {
      return Right(await remoteDataSource.getRefundEligibility(courseId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, RefundEntity>> requestRefund(
    String courseId,
    String reason,
  ) async {
    try {
      return Right(await remoteDataSource.requestRefund(courseId, reason));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<RefundEntity>>> getMyRefunds() async {
    try {
      return Right(await remoteDataSource.getMyRefunds());
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelRefund(String refundId) async {
    try {
      await remoteDataSource.cancelRefund(refundId);
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  // ── Payments & discounts ───────────────────────────────────────────────

  @override
  Future<Either<Failure, PaymentQuoteEntity>> getPaymentQuote(
    String courseId, {
    String? couponCode,
    String? corporateCouponId,
  }) async {
    try {
      return Right(await remoteDataSource.getPaymentQuote(
        courseId,
        couponCode: couponCode,
        corporateCouponId: corporateCouponId,
      ));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<CorporateCouponEntity>>> getCorporateCouponsForCourse(
    String courseId,
  ) async {
    try {
      return Right(await remoteDataSource.getCorporateCouponsForCourse(courseId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, PaymentInitiationEntity>> initiatePayment({
    required String courseId,
    String? couponCode,
    String? corporateCouponId,
    String? phone,
  }) async {
    try {
      return Right(await remoteDataSource.initiatePayment(
        courseId: courseId,
        couponCode: couponCode,
        corporateCouponId: corporateCouponId,
        phone: phone,
      ));
    } catch (e) {
      return Left(_map(e));
    }
  }

  // ── Free live ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getActiveFreeLiveClasses() async {
    try {
      return Right(await remoteDataSource.getActiveFreeLiveClasses());
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> joinFreeLiveClass(String id) async {
    try {
      return Right(await remoteDataSource.joinFreeLiveClass(id));
    } catch (e) {
      return Left(_map(e));
    }
  }

  // ── Notifications & announcements ──────────────────────────────────────

  @override
  Future<Either<Failure, List<NotificationEntity>>> getMyNotifications() async {
    try {
      return Right(await remoteDataSource.getMyNotifications());
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadNotificationCount() async {
    try {
      return Right(await remoteDataSource.getUnreadNotificationCount());
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> markNotificationRead(String id) async {
    try {
      await remoteDataSource.markNotificationRead(id);
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllNotificationsRead() async {
    try {
      await remoteDataSource.markAllNotificationsRead();
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getActiveAnnouncements() async {
    try {
      return Right(await remoteDataSource.getActiveAnnouncements());
    } catch (e) {
      return Left(_map(e));
    }
  }

  // ── Teacher evaluation ─────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> submitTeacherEvaluation(
    TeacherEvaluationEntity evaluation,
  ) async {
    try {
      await remoteDataSource.submitTeacherEvaluation(evaluation.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, TeacherEvaluationEntity?>> getMyTeacherEvaluation(
    String courseId,
  ) async {
    try {
      return Right(await remoteDataSource.getMyTeacherEvaluation(courseId));
    } catch (e) {
      return Left(_map(e));
    }
  }

  // ── Pre-booking ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> createPreBooking({
    required String courseId,
    String? studentName,
    String? phone,
    String? email,
  }) async {
    try {
      await remoteDataSource.createPreBooking({
        'courseId': courseId,
        if (studentName != null) 'studentName': studentName,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      });
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  // ── Support ────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> submitSupportTicket({
    required String message,
    String? subject,
  }) async {
    try {
      await remoteDataSource.submitSupportTicket({
        'message': message,
        if (subject != null) 'subject': subject,
      });
      return const Right(unit);
    } catch (e) {
      return Left(_map(e));
    }
  }

  /// Translates a data-layer exception into a domain [Failure].
  Failure _map(Object error) {
    if (error is RateLimitFailure) return error;
    if (error is AuthException) return AuthFailure(error.message);
    if (error is NetworkException) return NetworkFailure(error.message);
    if (error is CacheException) return CacheFailure(error.message);
    if (error is ServerException) {
      if (error.statusCode == 429) {
        return RateLimitFailure(
          retryAfterSeconds: error.retryAfterSeconds ?? 60,
          message: error.message,
        );
      }
      if (error.statusCode == 404) return NotFoundFailure(error.message);
      return ServerFailure(error.message, statusCode: error.statusCode);
    }
    return ServerFailure(error.toString().replaceFirst('Exception: ', '').trim());
  }
}