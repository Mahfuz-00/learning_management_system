import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Presentation/Auth/Pages/login_page.dart';
import '../../Presentation/Auth/Pages/register_page.dart';
import '../../Presentation/Auth/Pages/splash_page.dart';
import '../../Presentation/Auth/Pages/forgot_password_page.dart';
import '../../Presentation/Auth/Pages/otp_page.dart';
import '../../Presentation/Auth/Pages/new_password_page.dart';
import '../../Presentation/Auth/Pages/success_page.dart';
import '../../Presentation/Auth/Bloc/auth_bloc.dart';
import '../../Presentation/Course/Bloc/course_bloc.dart';
import '../../Presentation/Course/Pages/course_details_page.dart';
import '../../Presentation/Course/Pages/lesson_player_page.dart';
import '../../Presentation/Course/Pages/quiz_page.dart';
import '../../Presentation/Student/Pages/student_main_page.dart';
import '../../Presentation/Student/Pages/student_home_page.dart';
import '../../Presentation/Student/Pages/student_courses_page.dart';
import '../../Presentation/Student/Pages/student_profile_page.dart';
import '../../Presentation/Student/Pages/student_classes_page.dart';
import '../../Presentation/Student/Pages/student_store_page.dart';
import '../../Presentation/Teacher/Pages/teacher_main_page.dart';
import '../../Presentation/Teacher/Pages/teacher_home_page.dart';
import '../../Presentation/Teacher/Pages/teacher_courses_page.dart';
import '../../Presentation/Teacher/Pages/teacher_profile_page.dart';
import '../../Domain/Entities/lesson_entity.dart';
import '../../Core/DI/injection_container.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String newPassword = '/new-password';
  static const String authSuccess = '/auth-success';
  
  // Student Routes
  static const String studentHome = '/student-home';
  static const String studentCourses = '/student-courses';
  static const String studentClasses = '/student-classes';
  static const String studentStore = '/student-store';
  static const String studentProfile = '/student-profile';
  static const String courseDetails = '/course-details/:courseId';
  static const String lessonPlayer = '/lesson-player';
  static const String quiz = '/quiz/:lessonId';

  // Teacher Routes
  static const String teacherHome = '/teacher-home';
  static const String teacherCourses = '/teacher-courses';
  static const String teacherProfile = '/teacher-profile';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: const RegisterPage(),
        ),
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
          final courseId = state.pathParameters['courseId']!;
          return BlocProvider(
            create: (context) => sl<CourseBloc>(),
            child: CourseDetailsPage(courseId: courseId),
          );
        },
      ),
      GoRoute(
        path: lessonPlayer,
        builder: (context, state) {
          final lesson = state.extra as LessonEntity;
          return BlocProvider.value(
            value: sl<CourseBloc>(),
            child: LessonPlayerPage(lesson: lesson),
          );
        },
      ),
      GoRoute(
        path: quiz,
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return BlocProvider(
            create: (context) => sl<CourseBloc>(),
            child: QuizPage(lessonId: lessonId),
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
            path: studentCourses,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<CourseBloc>(),
              child: const StudentCoursesPage(),
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
            builder: (context, state) => const StudentStorePage(),
          ),
          GoRoute(
            path: studentProfile,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<AuthBloc>(),
              child: const StudentProfilePage(),
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
            path: teacherCourses,
            builder: (context, state) => BlocProvider(
              create: (context) => sl<CourseBloc>(),
              child: const TeacherCoursesPage(),
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
    ],
  );
}
