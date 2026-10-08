// Hand-written fakes shared by the unit tests.
//
// No mocking package is used: every fake implements the real interface and only
// the methods a test exercises are supported. Anything else throws, so an
// unexpected call fails loudly instead of silently returning null.

import 'package:dartz/dartz.dart';

import 'package:lms_touch_and_solve/Core/Error/failures.dart';
import 'package:lms_touch_and_solve/Domain/Entities/course_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/notification_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/payment_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/progress_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/refund_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/store_item_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/student_profile_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/user_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/user_preference_entity.dart';
import 'package:lms_touch_and_solve/Domain/Repositories/auth_repository.dart';
import 'package:lms_touch_and_solve/Domain/Repositories/course_repository.dart';
import 'package:lms_touch_and_solve/Domain/Repositories/learning_repository.dart';
import 'package:lms_touch_and_solve/Domain/Repositories/store_repository.dart';

/// ---------------------------------------------------------------------------
/// Auth
/// ---------------------------------------------------------------------------

/// Configurable [AuthRepository] fake.
///
/// Set [loginResult] / [profileResult] etc. per test. Calls are recorded so a
/// test can assert an event actually reached the repository.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.loginResult,
    this.registerResult = const Right(unit),
    this.profileResult,
    this.loggedInResult = const Right(true),
    this.changePasswordResult = const Right(unit),
  });

  Either<Failure, UserEntity>? loginResult;
  Either<Failure, Unit> registerResult;
  Either<Failure, UserEntity>? profileResult;
  Either<Failure, bool> loggedInResult;
  Either<Failure, Unit> changePasswordResult;

  final List<String> loginCalls = [];
  final List<Map<String, dynamic>> registerCalls = [];
  int logoutCalls = 0;
  int profileCalls = 0;

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    loginCalls.add('$email:$password');
    return loginResult ?? const Left(ServerFailure('login result not configured'));
  }

  @override
  Future<Either<Failure, Unit>> register(Map<String, dynamic> signupData) async {
    registerCalls.add(signupData);
    return registerResult;
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    profileCalls++;
    return profileResult ?? const Left(ServerFailure('no profile'));
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async => loggedInResult;

  @override
  Future<void> logout() async => logoutCalls++;

  @override
  Future<Either<Failure, Unit>> changePassword(
    String currentPassword,
    String newPassword,
  ) async =>
      changePasswordResult;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} not used in this test');
}

/// ---------------------------------------------------------------------------
/// Courses / wishlist
/// ---------------------------------------------------------------------------

/// Configurable [CourseRepository] fake covering the flows under test.
class FakeCourseRepository implements CourseRepository {
  FakeCourseRepository({
    this.courses = const [],
    this.enrolled = const [],
    this.wishlist = const [],
    this.failToggle = false,
    this.failGetAll = false,
  });

  List<CourseEntity> courses;
  List<CourseEntity> enrolled;
  List<CourseEntity> wishlist;
  bool failToggle;
  bool failGetAll;

  /// Optional override for the preference flow (PreferenceBloc).
  Either<Failure, UserPreferenceEntity>? preferencesResult;

  int getAllCoursesCalls = 0;
  int toggleCalls = 0;

  /// When set, `toggleWishlist` waits on this before completing — lets a test
  /// observe the in-flight state.
  Future<void>? toggleGate;

  @override
  Future<Either<Failure, List<CourseEntity>>> getAllCourses() async {
    getAllCoursesCalls++;
    if (failGetAll) return const Left(ServerFailure('catalogue down'));
    return Right(courses);
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getMyEnrollments() async =>
      Right(enrolled);

  /// Teacher-assigned courses (TeacherHomePage). Defaults to the catalogue so a
  /// seeded test sees the same list in both places unless it overrides this.
  @override
  Future<Either<Failure, List<CourseEntity>>> getTeacherCourses() async =>
      Right(teacherCourses ?? courses);

  /// Optional separate list for the teacher dashboard.
  List<CourseEntity>? teacherCourses;

  @override
  Future<Either<Failure, List<CourseEntity>>> getMyWishlist() async =>
      Right(wishlist);

  @override
  Future<Either<Failure, Unit>> toggleWishlist(String courseId) async {
    toggleCalls++;
    if (toggleGate != null) await toggleGate;
    if (failToggle) return const Left(ServerFailure('Network error'));
    return const Right(unit);
  }

  @override
  Future<Either<Failure, CourseEntity>> getCourseById(String id) async {
    final match = courses.where((c) => c.id == id);
    if (match.isEmpty) return const Left(ServerFailure('not found'));
    return Right(match.first);
  }

  @override
  Future<Either<Failure, UserPreferenceEntity>> getUserPreferences() async =>
      preferencesResult ??
      const Right(UserPreferenceEntity(
        categories: [],
        learningGoal: '',
        dailyTime: '',
      ));

  @override
  Future<Either<Failure, Unit>> saveUserPreferences(
    UserPreferenceEntity preferences,
  ) async =>
      const Right(unit);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} not used in this test');
}

/// ---------------------------------------------------------------------------
/// Misc
/// ---------------------------------------------------------------------------

/// Placeholder used where an interface method needs a value but the test never
/// calls it.
Never unsupported(String method) =>
    throw UnsupportedError('$method not used in this test');

/// Re-exported so tests do not need to import the profile entity directly.
typedef FakeProfile = StudentProfileEntity;

/// ---------------------------------------------------------------------------
/// Learning (exams, progress, refunds, notifications, payments)
/// ---------------------------------------------------------------------------

/// Configurable [LearningRepository] fake.
///
/// Set the `*Result` fields per test. List-returning methods default to an empty
/// success so unrelated calls do not fail.
class FakeLearningRepository implements LearningRepository {
  FakeLearningRepository({
    this.progressResult,
    this.historyResult,
    this.eligibilityResult,
    this.requestRefundResult,
    this.myRefundsResult,
    this.notificationsResult,
    this.unreadCountResult,
    this.announcementsResult,
    this.quoteResult,
  });

  Either<Failure, List<CourseProgressEntity>>? progressResult;
  Either<Failure, List<WatchHistoryItemEntity>>? historyResult;
  Either<Failure, RefundEligibilityEntity>? eligibilityResult;
  Either<Failure, RefundEntity>? requestRefundResult;
  Either<Failure, List<RefundEntity>>? myRefundsResult;
  Either<Failure, List<NotificationEntity>>? notificationsResult;
  Either<Failure, int>? unreadCountResult;
  Either<Failure, List<AnnouncementEntity>>? announcementsResult;
  Either<Failure, PaymentQuoteEntity>? quoteResult;

  int hideCalls = 0;
  int restoreCalls = 0;
  int markAllReadCalls = 0;
  final List<String> markedReadIds = [];

  @override
  Future<Either<Failure, List<CourseProgressEntity>>> getMyProgress() async =>
      progressResult ?? const Right([]);

  @override
  Future<Either<Failure, List<WatchHistoryItemEntity>>> getWatchHistory(String userId) async =>
      historyResult ?? const Right([]);

  @override
  Future<Either<Failure, Unit>> hideWatchHistoryItem(
    String userId,
    String contentId, {
    required bool isRecording,
  }) async {
    hideCalls++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> restoreWatchHistoryItem(
    String userId,
    String contentId, {
    required bool isRecording,
  }) async {
    restoreCalls++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, RefundEligibilityEntity>> getRefundEligibility(String courseId) async =>
      eligibilityResult ?? const Left(ServerFailure('not configured'));

  @override
  Future<Either<Failure, RefundEntity>> requestRefund(String courseId, String reason) async =>
      requestRefundResult ?? const Left(ServerFailure('not configured'));

  @override
  Future<Either<Failure, List<RefundEntity>>> getMyRefunds() async =>
      myRefundsResult ?? const Right([]);

  @override
  Future<Either<Failure, Unit>> cancelRefund(String refundId) async => const Right(unit);

  @override
  Future<Either<Failure, List<NotificationEntity>>> getMyNotifications() async =>
      notificationsResult ?? const Right([]);

  @override
  Future<Either<Failure, int>> getUnreadNotificationCount() async =>
      unreadCountResult ?? const Right(0);

  @override
  Future<Either<Failure, Unit>> markNotificationRead(String id) async {
    markedReadIds.add(id);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> markAllNotificationsRead() async {
    markAllReadCalls++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getActiveAnnouncements() async =>
      announcementsResult ?? const Right([]);

  @override
  Future<Either<Failure, PaymentQuoteEntity>> getPaymentQuote(
    String courseId, {
    String? couponCode,
    String? corporateCouponId,
  }) async =>
      quoteResult ?? const Left(ServerFailure('not configured'));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} not used in this test');
}

/// Configurable [StoreRepository] fake.
class FakeStoreRepository implements StoreRepository {
  FakeStoreRepository({this.itemsResult});

  Either<Failure, List<StoreItemEntity>>? itemsResult;

  @override
  Future<Either<Failure, List<StoreItemEntity>>> getStoreItems() async =>
      itemsResult ?? const Right([]);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} not used in this test');
}

/// ---------------------------------------------------------------------------
/// Entity factories
/// ---------------------------------------------------------------------------

NotificationEntity buildNotification({
  String id = 'n1',
  String title = 'New lesson',
  bool isRead = false,
}) {
  return NotificationEntity(
    id: id,
    title: title,
    message: 'You have an update',
    isRead: isRead,
  );
}

WatchHistoryItemEntity buildHistoryItem({
  String id = 'h1',
  String contentId = 'l1',
  DateTime? lastWatchedAt,
  bool isHidden = false,
}) {
  return WatchHistoryItemEntity(
    id: id,
    contentId: contentId,
    contentType: 'lesson',
    title: 'Lesson $contentId',
    watchedSeconds: 300,
    totalSeconds: 600,
    lastWatchedAt: lastWatchedAt,
    isHidden: isHidden,
  );
}

RefundEntity buildRefund({
  String id = 'r1',
  String courseId = 'c1',
  RefundStatus status = RefundStatus.requested,
}) {
  return RefundEntity(
    id: id,
    courseId: courseId,
    courseTitle: 'Course $courseId',
    reason: 'Changed my mind',
    status: status,
  );
}
