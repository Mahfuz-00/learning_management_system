import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../Domain/Entities/ai_writing_entity.dart';
import '../../Domain/Entities/course_entity.dart';
import '../../Domain/Entities/exam_entity.dart';
import '../../Domain/Entities/lesson_entity.dart';
import '../../Domain/Entities/live_class_entity.dart';
import '../../Domain/Entities/practice_entity.dart';
import '../../Presentation/Auth/Bloc/auth_bloc.dart';
import '../../Presentation/Auth/Bloc/auth_state.dart';
import '../../Presentation/Auth/Pages/forgot_password_page.dart';
import '../../Presentation/Auth/Pages/login_page.dart';
import '../../Presentation/Auth/Pages/new_password_page.dart';
import '../../Presentation/Auth/Pages/otp_page.dart';
import '../../Presentation/Auth/Pages/pending_approval_page.dart';
import '../../Presentation/Auth/Pages/signup_stepper_page.dart';
import '../../Presentation/Auth/Pages/splash_page.dart';
import '../../Presentation/Auth/Pages/success_page.dart';
import '../../Presentation/Checkout/Bloc/checkout_bloc.dart';
import '../../Presentation/Checkout/Pages/checkout_page.dart';
import '../../Presentation/Course/Bloc/course_bloc.dart';
import '../../Presentation/Course/Bloc/lesson_bloc.dart';
import '../../Presentation/Course/Bloc/video_download_bloc.dart';
import '../../Presentation/Course/Pages/course_details_page.dart';
import '../../Presentation/Course/Pages/course_hub_page.dart';
import '../../Presentation/Course/Pages/enrolled_course_workspace.dart';
import '../../Presentation/Course/Pages/lesson_player_page.dart';
import '../../Presentation/Course/Pages/live_class_page.dart';
import '../../Presentation/Course/Pages/quiz_player_page.dart';
import '../../Presentation/Course/Pages/quiz_results_page.dart';
import '../../Presentation/FreeLive/Pages/free_live_page.dart';
import '../../Presentation/Learning/Bloc/learning_bloc.dart';
import '../../Presentation/Learning/Pages/ai_writing_list_page.dart';
import '../../Presentation/Learning/Pages/ai_writing_page.dart';
import '../../Presentation/Learning/Pages/course_exams_page.dart';
import '../../Presentation/Learning/Pages/exam_submissions_page.dart';
import '../../Presentation/Learning/Pages/exam_submit_page.dart';
import '../../Presentation/Learning/Pages/live_classes_list_page.dart';
import '../../Presentation/Learning/Pages/live_exam_page.dart';
import '../../Presentation/Learning/Pages/practice_viewer_page.dart';
import '../../Presentation/Learning/Pages/recordings_list_page.dart';
import '../../Presentation/Notifications/Bloc/notification_bloc.dart';
import '../../Presentation/Notifications/Pages/announcements_page.dart';
import '../../Presentation/Notifications/Pages/notifications_page.dart';
import '../../Presentation/Profile/Bloc/profile_bloc.dart';
import '../../Presentation/Profile/Pages/onboarding_page.dart';
import '../../Presentation/Progress/Bloc/progress_bloc.dart';
import '../../Presentation/Progress/Pages/leaderboard_page.dart';
import '../../Presentation/Progress/Pages/watch_history_page.dart';
import '../../Presentation/Refund/Bloc/refund_bloc.dart';
import '../../Presentation/Refund/Pages/refund_page.dart';
import '../../Presentation/Student/Bloc/store_bloc.dart';
import '../../Presentation/Student/Pages/student_browse_page.dart';
import '../../Presentation/Student/Pages/student_certificates_page.dart';
import '../../Presentation/Student/Pages/student_classes_page.dart';
import '../../Presentation/Student/Pages/student_home_page.dart';
import '../../Presentation/Student/Pages/student_main_page.dart';
import '../../Presentation/Student/Pages/student_profile_page.dart';
import '../../Presentation/Student/Pages/student_store_page.dart';
import '../../Presentation/Student/Pages/student_wishlist_page.dart';
import '../../Presentation/Teacher/Pages/teacher_add_lesson_page.dart';
import '../../Presentation/Teacher/Pages/teacher_add_quiz_page.dart';
import '../../Presentation/Teacher/Pages/teacher_course_details_page.dart';
import '../../Presentation/Teacher/Pages/teacher_course_management_page.dart';
import '../../Presentation/Teacher/Pages/teacher_create_course_page.dart';
import '../../Presentation/Teacher/Pages/teacher_home_page.dart';
import '../../Presentation/Teacher/Pages/teacher_main_page.dart';
import '../../Presentation/Teacher/Pages/teacher_profile_page.dart';
import '../../Presentation/Teacher/Pages/teacher_schedule_class_page.dart';
import '../../Presentation/Teacher/Pages/teacher_student_roster_page.dart';
import 'router_refresh_stream.dart';
import '../DI/injection_container.dart';

/// Application routing table and access-control guards.
///
/// **Navigation model.** Routes never navigate imperatively after a login. The
/// BLoC emits a new state, [GoRouterRefreshStream] notifies GoRouter, and
/// [GoRouter.redirect] decides where the user is allowed to be. That keeps a
/// single source of truth for access control.
class AppRouter {
  AppRouter._();

  // ── Public routes (no login required) ──────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String pendingApproval = '/pending-approval';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String newPassword = '/new-password';
  static const String authSuccess = '/auth-success';

  /// **Rule 12:** `/free-live` is fully public — *"Anyone can watch without
  /// logging in or registering."*
  static const String freeLive = '/free-live';

  static const String announcements = '/announcements';

  // ── Student shell ──────────────────────────────────────────────────────
  static const String studentHome = '/student';
  static const String studentBrowse = '/student/browse';
  static const String studentWishlist = '/student/wishlist';
  static const String studentProfile = '/student/profile';
  static const String studentClasses = '/student/classes';
  static const String studentStore = '/student/store';
  static const String studentCertificates = '/student/certificates';

  // ── Student feature routes ─────────────────────────────────────────────
  static const String onboarding = '/onboarding';
  static const String notifications = '/notifications';
  static const String history = '/history';
  static const String leaderboard = '/leaderboard';

  // ── Course routes ──────────────────────────────────────────────────────
  static const String courseDetails = '/course/:id';
  static const String enrolledWorkspace = '/workspace/:id';
  static const String courseHub = '/hub/:id';
  static const String lessonPlayer = '/lesson-player';
  static const String quizPlayer = '/quiz-player/:lessonId';
  static const String quizResults = '/quiz-results';
  static const String liveClass = '/live-class';
  static const String checkout = '/checkout/:id';
  static const String refund = '/refund/:courseId';

  // ── Learning routes ────────────────────────────────────────────────────
  static const String courseExams = '/course-exams/:courseId';
  static const String examSubmit = '/exam-submit/:examId';
  static const String examSubmissions = '/exam-submissions/:examId';
  static const String liveExam = '/live-exam/:examId';
  static const String aiWritingList = '/ai-writing-list/:courseId';
  static const String aiWriting = '/ai-writing/:taskId';
  static const String practice = '/practice/:courseId';
  static const String suggestions = '/suggestions/:courseId';
  static const String liveClassesList = '/live-classes/:courseId';
  static const String recordings = '/recordings/:courseId';

  // ── Teacher routes ─────────────────────────────────────────────────────
  static const String teacherHome = '/teacher';
  static const String teacherCourseManagement = '/teacher/courses';
  static const String teacherCreateCourse = '/teacher/create-course';
  static const String teacherAddLesson = '/teacher/add-lesson/:courseId';
  static const String teacherAddQuiz = '/teacher/add-quiz/:lessonId';
  static const String teacherCourseDetails = '/teacher/course-details/:courseId';
  static const String teacherRoster = '/teacher/roster/:courseId';
  static const String teacherScheduleClass = '/teacher/schedule-class/:courseId';
  static const String teacherProfile = '/teacher/profile';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    debugLogDiagnostics: true,
    routes: [
      // ── Public ─────────────────────────────────────────────────────────
      GoRoute(path: splash, builder: (context, state) => const SplashPage()),
      GoRoute(path: login, builder: (context, state) => const LoginPage()),
      GoRoute(path: signup, builder: (context, state) => const SignupStepperPage()),
      GoRoute(
        path: pendingApproval,
        builder: (context, state) => const PendingApprovalPage(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(path: otp, builder: (context, state) => const OtpPage()),
      GoRoute(
        path: newPassword,
        builder: (context, state) => const NewPasswordPage(),
      ),
      GoRoute(
        path: authSuccess,
        builder: (context, state) {
          final message = state.extra as String? ?? 'Operation successful';
          return SuccessPage(message: message);
        },
      ),

      // Rule 12: public — no auth guard, no token required.
      GoRoute(path: freeLive, builder: (context, state) => const FreeLivePage()),

      GoRoute(
        path: announcements,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<NotificationBloc>(),
          child: const AnnouncementsPage(),
        ),
      ),

      // ── Onboarding (compulsory after verification) ─────────────────────
      GoRoute(
        path: onboarding,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<ProfileBloc>(),
          child: const OnboardingPage(),
        ),
      ),

      // ── Notifications / history / leaderboard ──────────────────────────
      GoRoute(
        path: notifications,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<NotificationBloc>(),
          child: const NotificationsPage(),
        ),
      ),
      GoRoute(
        path: history,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<ProgressBloc>(),
          child: const WatchHistoryPage(),
        ),
      ),
      GoRoute(
        path: leaderboard,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CourseBloc>(),
          child: const LeaderboardPage(),
        ),
      ),

      // ── Course details & hub ───────────────────────────────────────────
      GoRoute(
        path: courseDetails,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CourseBloc>(),
          child: CourseDetailsPage(courseId: state.pathParameters['id']!),
        ),
      ),

      /// The enrolled-course hub with the five cards (Manual §4.3).
      GoRoute(
        path: courseHub,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final course = state.extra as CourseEntity?;
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => sl<CourseBloc>()),
              BlocProvider(create: (context) => sl<LearningBloc>()),
              BlocProvider(create: (context) => sl<ProgressBloc>()),
            ],
            child: CourseHubPage(courseId: id, course: course),
          );
        },
      ),

      GoRoute(
        path: enrolledWorkspace,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final course = state.extra as CourseEntity?;
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => sl<CourseBloc>()),
              BlocProvider(create: (context) => sl<VideoDownloadBloc>()),
            ],
            child: EnrolledCourseWorkspace(courseId: id, course: course),
          );
        },
      ),

      GoRoute(
        path: lessonPlayer,
        builder: (context, state) {
          final lesson = state.extra as LessonEntity;
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => sl<LessonBloc>()),
              BlocProvider(create: (context) => sl<CourseBloc>()),
            ],
            child: LessonPlayerPage(lesson: lesson),
          );
        },
      ),

      GoRoute(
        path: quizPlayer,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CourseBloc>(),
          child: QuizPlayerPage(lessonId: state.pathParameters['lessonId']!),
        ),
      ),

      GoRoute(
        path: quizResults,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QuizResultsPage(
            score: extra['score'],
            totalQuestions: extra['totalQuestions'],
            correctAnswers: extra['correctAnswers'],
          );
        },
      ),

      GoRoute(
        path: liveClass,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return LiveClassPage(
            liveClass: extra['liveClass'] as LiveClassEntity,
            user: extra['user'],
          );
        },
      ),

      // ── Checkout (Rule 4) ──────────────────────────────────────────────
      GoRoute(
        path: checkout,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (context) => sl<CheckoutBloc>(),
            child: CheckoutPage(
              courseId: id,
              courseTitle: extra?['title']?.toString() ?? 'Course',
              originalPrice:
                  double.tryParse(extra?['price']?.toString() ?? '0') ?? 0,
            ),
          );
        },
      ),

      // ── Refunds (Rule 9) ───────────────────────────────────────────────
      GoRoute(
        path: refund,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (context) => sl<RefundBloc>(),
            child: RefundPage(
              courseId: state.pathParameters['courseId']!,
              courseTitle: extra?['title']?.toString() ?? 'Course',
            ),
          );
        },
      ),

      // ── Learning: exams, live exams, AI writing, practice ──────────────
      GoRoute(
        path: courseExams,
        builder: (context, state) {
          final extra = state.extra as List<ExamEntity>?;
          return BlocProvider(
            create: (context) => sl<LearningBloc>(),
            child: CourseExamsPage(
              courseId: state.pathParameters['courseId']!,
              initialExams: extra,
            ),
          );
        },
      ),

      GoRoute(
        path: examSubmit,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<LearningBloc>(),
          child: ExamSubmitPage(examId: state.pathParameters['examId']!),
        ),
      ),

      /// Teacher marking queue. `?readOnly=true` is used for the admin
      /// read-only view described in Manual §5.2.
      GoRoute(
        path: examSubmissions,
        builder: (context, state) {
          final readOnly =
              state.uri.queryParameters['readOnly']?.toLowerCase() == 'true';
          return BlocProvider(
            create: (context) => sl<LearningBloc>(),
            child: ExamSubmissionsPage(
              examId: state.pathParameters['examId']!,
              readOnly: readOnly,
            ),
          );
        },
      ),

      GoRoute(
        path: liveExam,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<LearningBloc>(),
          child: LiveExamPage(examId: state.pathParameters['examId']!),
        ),
      ),

      GoRoute(
        path: aiWritingList,
        builder: (context, state) {
          final extra = state.extra as List<AiWritingTaskEntity>?;
          return BlocProvider(
            create: (context) => sl<LearningBloc>(),
            child: AiWritingListPage(
              courseId: state.pathParameters['courseId']!,
              initialTasks: extra,
            ),
          );
        },
      ),

      GoRoute(
        path: aiWriting,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<LearningBloc>(),
          child: AiWritingPage(taskId: state.pathParameters['taskId']!),
        ),
      ),

      GoRoute(
        path: practice,
        builder: (context, state) {
          final files = (state.extra as List<PracticeEntity>?) ?? const [];
          return PracticeViewerPage(title: 'Practice', files: files);
        },
      ),

      GoRoute(
        path: suggestions,
        builder: (context, state) {
          final files = (state.extra as List<PracticeEntity>?) ?? const [];
          return PracticeViewerPage(title: 'Exam Suggestions', files: files);
        },
      ),

      GoRoute(
        path: liveClassesList,
        builder: (context, state) {
          final classes = (state.extra as List<LiveClassEntity>?) ?? const [];
          return LiveClassesListPage(
            courseId: state.pathParameters['courseId']!,
            liveClasses: classes,
          );
        },
      ),

      GoRoute(
        path: recordings,
        builder: (context, state) {
          final recordings = (state.extra as List<LiveClassEntity>?) ?? const [];
          return RecordingsListPage(
            courseId: state.pathParameters['courseId']!,
            recordings: recordings,
          );
        },
      ),

      // ── Student shell ──────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => StudentMainPage(child: child),
        routes: [
          GoRoute(
            path: studentHome,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<CourseBloc>(),
              child: const StudentHomePage(),
            ),
          ),
          GoRoute(
            path: studentBrowse,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<CourseBloc>(),
              child: const StudentBrowsePage(),
            ),
          ),
          GoRoute(
            path: studentWishlist,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<CourseBloc>(),
              child: const StudentWishlistPage(),
            ),
          ),
          GoRoute(
            path: studentClasses,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<CourseBloc>(),
              child: const StudentClassesPage(),
            ),
          ),
          GoRoute(
            path: studentStore,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<StoreBloc>(),
              child: const StudentStorePage(),
            ),
          ),
          GoRoute(
            path: studentProfile,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<AuthBloc>(),
              child: const StudentProfilePage(),
            ),
          ),
          GoRoute(
            path: studentCertificates,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<AuthBloc>(),
              child: const StudentCertificatesPage(),
            ),
          ),
        ],
      ),

      // ── Teacher shell ──────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => TeacherMainPage(child: child),
        routes: [
          GoRoute(
            path: teacherHome,
            builder: (context, state) => const TeacherHomePage(),
          ),
          GoRoute(
            path: teacherCourseManagement,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<CourseBloc>(),
              child: const TeacherCourseManagementPage(),
            ),
          ),
          GoRoute(
            path: teacherProfile,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<AuthBloc>(),
              child: const TeacherProfilePage(),
            ),
          ),
        ],
      ),

      // ── Teacher management pages ───────────────────────────────────────
      GoRoute(
        path: teacherCreateCourse,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CourseBloc>(),
          child: const TeacherCreateCoursePage(),
        ),
      ),
      GoRoute(
        path: teacherAddLesson,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CourseBloc>(),
          child: TeacherAddLessonPage(
            courseId: state.pathParameters['courseId']!,
          ),
        ),
      ),
      GoRoute(
        path: teacherAddQuiz,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CourseBloc>(),
          child: TeacherAddQuizPage(
            lessonId: state.pathParameters['lessonId']!,
          ),
        ),
      ),
      GoRoute(
        path: teacherCourseDetails,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CourseBloc>(),
          child: TeacherCourseDetailsPage(
            courseId: state.pathParameters['courseId']!,
          ),
        ),
      ),
      GoRoute(
        path: teacherRoster,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CourseBloc>(),
          child: TeacherStudentRosterPage(
            courseId: state.pathParameters['courseId']!,
          ),
        ),
      ),
      GoRoute(
        path: teacherScheduleClass,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CourseBloc>(),
          child: TeacherScheduleClassPage(
            courseId: state.pathParameters['courseId']!,
          ),
        ),
      ),
    ],

    /// Central access-control guard.
    ///
    /// Rules enforced here:
    /// - **Rule 12** — `/free-live` and `/announcements` stay reachable while
    ///   logged out; everything else bounces to `/login`.
    /// - **Rule 1** — students may not enter `/teacher/*`, and teachers may not
    ///   enter student-only screens. Without this, a student could reach the
    ///   course-authoring UI directly.
    /// - **Manual §5.1** — an unapproved teacher is pinned to
    ///   `/pending-approval` until an admin approves them.
    redirect: (context, state) {
      final authState = sl<AuthBloc>().state;
      final currentPath = state.uri.path;
      log('Router: state=$authState path=$currentPath');

      // The splash screen must always render so the app can boot.
      if (currentPath == splash) return null;

      // Rule 12: genuinely public routes, reachable with no session at all.
      const publicPaths = {freeLive, announcements, pendingApproval};

      final isAuthRoute = currentPath == login ||
          currentPath == signup ||
          currentPath == forgotPassword ||
          currentPath == otp ||
          currentPath == newPassword;

      if (authState is Unauthenticated) {
        if (isAuthRoute || publicPaths.contains(currentPath)) return null;
        return login;
      }

      if (authState is Authenticated) {
        final user = authState.user;

        // Manual §5.1: teachers created by self-signup wait for admin approval.
        if (user.isTeacher && user.status != 'Approved') {
          return currentPath == pendingApproval ? null : pendingApproval;
        }

        // Already signed in — do not show the login/register screens.
        if (isAuthRoute) {
          return user.isStudent ? studentHome : teacherHome;
        }

        // ── Rule 1: role separation ────────────────────────────────────
        final isTeacherRoute = currentPath.startsWith('/teacher');
        if (isTeacherRoute && !user.isTeacher) {
          // A student must never reach course-authoring or grading screens.
          return studentHome;
        }

        return null;
      }

      return null;
    },
  );
}