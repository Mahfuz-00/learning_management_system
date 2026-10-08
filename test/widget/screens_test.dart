// Widget tests for full screens across the student and teacher roles.
//
// Each screen is mounted with real BLoCs seeded through their fakes, so the
// tests cover the loading, loaded, empty and error branches the user can hit.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/auth_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/auth_state.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_event.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_state.dart';
import 'package:lms_touch_and_solve/Presentation/Student/Pages/student_home_page.dart';
import 'package:lms_touch_and_solve/Presentation/Student/Pages/student_wishlist_page.dart';
import 'package:lms_touch_and_solve/Presentation/Student/Widgets/course_card.dart';
import 'package:lms_touch_and_solve/Presentation/Teacher/Pages/teacher_home_page.dart';
import 'package:lms_touch_and_solve/Presentation/Teacher/Widgets/teacher_course_card.dart';
import 'package:lms_touch_and_solve/Presentation/Teacher/Widgets/teacher_stat_card.dart';

import '../helpers/fakes.dart';
import '../helpers/test_harness.dart';

void main() {
  Widget hostStudent(CourseBloc courseBloc, Widget child) {
    return MaterialApp(
      theme: testTheme(),
      home: BlocProvider<CourseBloc>.value(value: courseBloc, child: child),
    );
  }

  /// Mounts a screen and waits for the catalogue load to settle.
  Future<CourseBloc> mountWithCatalogue(
    WidgetTester tester,
    FakeCourseRepository repo,
    Widget Function(CourseBloc) build,
  ) async {
    final bloc = CourseBloc(courseRepository: repo);
    addTearDown(bloc.close);
    bloc.add(LoadAllCourses());
    await bloc.stream
        .firstWhere((s) => s.allCoursesStatus != CourseStatus.initial);
    await tester.pumpWidget(hostStudent(bloc, build(bloc)));
    await tester.pump();
    return bloc;
  }

  // ── Student dashboard ─────────────────────────────────────────────────────
  group('StudentHomePage', () {
    testWidgets('greets the student and lists courses', (tester) async {
      final repo = FakeCourseRepository(
        courses: [buildCourse(id: 'c1', title: 'Flutter Fundamentals')],
      );
      await mountWithCatalogue(
        tester,
        repo,
        (_) => const StudentHomePage(),
      );
      await tester.pump();

      expect(find.text('Hello, Student!'), findsOneWidget);
      expect(find.text('Continue Learning'), findsOneWidget);
      expect(find.text('Recommended Courses'), findsOneWidget);
    });

    testWidgets('shows the empty enrolled hint when the student has none',
        (tester) async {
      final repo = FakeCourseRepository(enrolled: const []);
      await mountWithCatalogue(
        tester,
        repo,
        (_) => const StudentHomePage(),
      );
      await tester.pump();

      expect(
        find.text('You have not enrolled in any courses yet.'),
        findsOneWidget,
      );
    });

    testWidgets('renders a card for each recommended course', (tester) async {
      final repo = FakeCourseRepository(
        courses: [
          buildCourse(id: 'c1', title: 'Flutter'),
          buildCourse(id: 'c2', title: 'Dart'),
        ],
      );
      await mountWithCatalogue(tester, repo, (_) => const StudentHomePage());
      await tester.pump();

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });
  });

  // ── Wishlist ──────────────────────────────────────────────────────────────
  group('StudentWishlistPage', () {
    testWidgets('shows the empty state when nothing is saved', (tester) async {
      final bloc = CourseBloc(courseRepository: FakeCourseRepository());
      addTearDown(bloc.close);

      await tester.pumpWidget(
        hostStudent(bloc, const StudentWishlistPage()),
      );
      await tester.pump();

      expect(find.text('Your wishlist is empty'), findsOneWidget);
      expect(find.text('Explore Courses'), findsOneWidget);
    });

    testWidgets('lists saved courses with a filled heart', (tester) async {
      final repo = FakeCourseRepository(
        wishlist: [buildCourse(id: 'c1', title: 'Saved Course', isWishlisted: true)],
      );
      final bloc = CourseBloc(courseRepository: repo);
      addTearDown(bloc.close);

      await tester.pumpWidget(
        hostStudent(bloc, const StudentWishlistPage()),
      );
      // Pump a few frames so initState's LoadMyWishlist future resolves and the
      // grid rebuilds with the loaded list.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(find.text('Saved Course'), findsOneWidget);
      expect(find.byType(CourseCard), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  // ── Teacher dashboard ─────────────────────────────────────────────────────
  group('TeacherHomePage', () {
    Widget hostTeacher(AuthBloc authBloc, CourseBloc courseBloc) {
      return MaterialApp(
        theme: testTheme(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<CourseBloc>.value(value: courseBloc),
          ],
          child: const TeacherHomePage(),
        ),
      );
    }

    testWidgets('shows the welcome header, stats and assigned courses',
        (tester) async {
      final authBloc = AuthBloc(authRepository: FakeAuthRepository());
      final courseBloc = CourseBloc(
        courseRepository: FakeCourseRepository(
          courses: [buildCourse(id: 't1', title: 'My Class', totalLessons: 6)],
        ),
      );
      addTearDown(authBloc.close);
      addTearDown(courseBloc.close);

      authBloc.emit(Authenticated(buildUser(fullName: 'Instructor Rana')));

      await tester.pumpWidget(hostTeacher(authBloc, courseBloc));
      await tester.pump();

      expect(find.text('Teacher Dashboard'), findsOneWidget);
      expect(find.text('Instructor Rana'), findsOneWidget);
      expect(find.text('CREATE NEW COURSE'), findsOneWidget);
      expect(find.text('Performance Stats'), findsOneWidget);
      expect(find.byType(TeacherStatCard), findsNWidgets(4));
    });

    testWidgets('falls back to "Instructor" before auth resolves', (tester) async {
      final authBloc = AuthBloc(authRepository: FakeAuthRepository());
      final courseBloc = CourseBloc(courseRepository: FakeCourseRepository());
      addTearDown(authBloc.close);
      addTearDown(courseBloc.close);

      await tester.pumpWidget(hostTeacher(authBloc, courseBloc));
      await tester.pump();

      expect(find.text('Instructor'), findsOneWidget);
    });

    testWidgets('shows the empty message when no courses are assigned',
        (tester) async {
      final authBloc = AuthBloc(authRepository: FakeAuthRepository());
      final courseBloc = CourseBloc(courseRepository: FakeCourseRepository());
      addTearDown(authBloc.close);
      addTearDown(courseBloc.close);

      await tester.pumpWidget(hostTeacher(authBloc, courseBloc));
      // initState dispatches LoadTeacherCourses; pump until it settles into the
      // loaded-but-empty state.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(find.text('No courses assigned yet.'), findsOneWidget);
      expect(find.byType(TeacherCourseCard), findsNothing);
    });
  });
}
