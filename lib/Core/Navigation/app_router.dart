import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Presentation/Auth/Bloc/auth_bloc.dart';
import '../../Presentation/Auth/Bloc/auth_state.dart';
import '../../Presentation/Auth/Pages/login_page.dart';
import '../../Presentation/Auth/Pages/signup_stepper_page.dart';
import '../../Presentation/Auth/Pages/splash_page.dart';
import '../../Presentation/Auth/Pages/pending_approval_page.dart';
import '../../Presentation/Auth/Pages/forgot_password_page.dart';
import '../../Presentation/Auth/Pages/otp_page.dart';
import '../../Presentation/Auth/Pages/new_password_page.dart';
import '../../Presentation/Auth/Pages/success_page.dart';
import '../../Presentation/Student/Pages/student_main_page.dart';
import '../../Presentation/Student/Pages/student_home_page.dart';
import '../../Presentation/Student/Pages/student_browse_page.dart';
import '../../Presentation/Student/Pages/student_wishlist_page.dart';
import '../../Presentation/Student/Pages/student_profile_page.dart';
import '../../Presentation/Student/Pages/student_classes_page.dart';
import '../../Presentation/Student/Pages/student_store_page.dart';
import '../../Presentation/Student/Pages/student_certificates_page.dart';
import '../../Presentation/Course/Pages/course_details_page.dart';
import '../../Presentation/Course/Pages/enrolled_course_workspace.dart';
import '../../Presentation/Course/Pages/lesson_player_page.dart';
import '../../Presentation/Course/Pages/quiz_player_page.dart';
import '../../Presentation/Course/Pages/quiz_results_page.dart';
import '../../Presentation/Course/Pages/live_class_page.dart';
import '../../Presentation/Teacher/Pages/teacher_main_page.dart';
import '../../Presentation/Teacher/Pages/teacher_home_page.dart';
import '../../Presentation/Teacher/Pages/teacher_course_management_page.dart';
import '../../Presentation/Teacher/Pages/teacher_create_course_page.dart';
import '../../Presentation/Teacher/Pages/teacher_add_lesson_page.dart';
import '../../Presentation/Teacher/Pages/teacher_add_quiz_page.dart';
import '../../Presentation/Teacher/Pages/teacher_course_details_page.dart';
import '../../Presentation/Teacher/Pages/teacher_student_roster_page.dart';
import '../../Presentation/Teacher/Pages/teacher_schedule_class_page.dart';
import '../../Presentation/Teacher/Pages/teacher_profile_page.dart';
import '../../Domain/Entities/course_entity.dart';
import '../../Domain/Entities/lesson_entity.dart';
import '../../Domain/Entities/live_class_entity.dart';
import '../../Core/DI/injection_container.dart';
import '../../Presentation/Course/Bloc/course_bloc.dart';
import '../../Presentation/Course/Bloc/lesson_bloc.dart';
import '../../Presentation/Course/Bloc/video_download_bloc.dart';
import '../../Presentation/Student/Bloc/store_bloc.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String pendingApproval = '/pending-approval';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String newPassword = '/new-password';
  static const String authSuccess = '/auth-success';
  
  static const String studentHome = '/student';
  static const String studentBrowse = '/student/browse';
  static const String studentWishlist = '/student/wishlist';
  static const String studentProfile = '/student/profile';
  static const String studentClasses = '/student/classes';
  static const String studentStore = '/student/store';
  static const String studentCertificates = '/student/certificates';
  
  static const String teacherHome = '/teacher';
  static const String teacherCourseManagement = '/teacher/courses';
  static const String teacherCreateCourse = '/teacher/create-course';
  static const String teacherAddLesson = '/teacher/add-lesson/:courseId';
  static const String teacherAddQuiz = '/teacher/add-quiz/:lessonId';
  static const String teacherCourseDetails = '/teacher/course-details/:courseId';
  static const String teacherRoster = '/teacher/roster/:courseId';
  static const String teacherScheduleClass = '/teacher/schedule-class/:courseId';
  static const String teacherProfile = '/teacher/profile';

  static const String courseDetails = '/course/:id';
  static const String enrolledWorkspace = '/workspace/:id';
  static const String lessonPlayer = '/lesson-player';
  static const String quizPlayer = '/quiz-player/:lessonId';
  static const String quizResults = '/quiz-results';
  static const String liveClass = '/live-class';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) => const SignupStepperPage(),
      ),
      GoRoute(
        path: pendingApproval,
        builder: (context, state) => const PendingApprovalPage(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: otp,
        builder: (context, state) => const OtpPage(),
      ),
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
      
      GoRoute(
        path: courseDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (context) => sl<CourseBloc>(),
            child: CourseDetailsPage(courseId: id),
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
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return BlocProvider(
            create: (context) => sl<CourseBloc>(),
            child: QuizPlayerPage(lessonId: lessonId),
          );
        },
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

      // Student Shell
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

      // Teacher Shell
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

      // Teacher Management Pages
      GoRoute(
        path: teacherCreateCourse,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<CourseBloc>(),
          child: const TeacherCreateCoursePage(),
        ),
      ),
      GoRoute(
        path: teacherAddLesson,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return BlocProvider(
            create: (context) => sl<CourseBloc>(),
            child: TeacherAddLessonPage(courseId: courseId),
          );
        },
      ),
      GoRoute(
        path: teacherAddQuiz,
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return BlocProvider(
            create: (context) => sl<CourseBloc>(),
            child: TeacherAddQuizPage(lessonId: lessonId),
          );
        },
      ),
      GoRoute(
        path: teacherCourseDetails,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return BlocProvider(
            create: (context) => sl<CourseBloc>(),
            child: TeacherCourseDetailsPage(courseId: courseId),
          );
        },
      ),
      GoRoute(
        path: teacherRoster,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return BlocProvider(
            create: (context) => sl<CourseBloc>(),
            child: TeacherStudentRosterPage(courseId: courseId),
          );
        },
      ),
      GoRoute(
        path: teacherScheduleClass,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return BlocProvider(
            create: (context) => sl<CourseBloc>(),
            child: TeacherScheduleClassPage(courseId: courseId),
          );
        },
      ),
    ],
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final bool isLoggingIn = state.uri.path == login || 
                               state.uri.path == signup || 
                               state.uri.path == splash || 
                               state.uri.path == forgotPassword ||
                               state.uri.path == otp ||
                               state.uri.path == newPassword;

      if (authState is Unauthenticated) {
        return isLoggingIn ? null : login;
      }

      if (authState is Authenticated) {
        final user = authState.user;
        if (user.isTeacher && user.status != 'Approved') {
          return pendingApproval;
        }
        
        if (isLoggingIn) {
          return user.isStudent ? studentHome : teacherHome;
        }
      }

      return null;
    },
  );
}
