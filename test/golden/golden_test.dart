// Golden (visual regression) tests.
//
// These render a screen at a fixed surface size and compare the pixels against
// a checked-in PNG under `test/goldens/`. Any unintended visual change fails the
// test with a diff.
//
// Regenerate the reference images after an intentional UI change:
//
//     flutter test --update-goldens test/golden
//
// Determinism notes
// -----------------
// * The surface size and device pixel ratio are pinned by `pumpForGolden`.
// * Fonts are loaded by `test/flutter_test_config.dart` so text metrics match
//   across Windows / macOS / Linux CI.
// * Course thumbnails are intentionally left null: `AppNetworkImage` then draws
//   its deterministic offline placeholder instead of fetching from the network,
//   so the golden never depends on a live server.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/auth_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/auth_state.dart';
import 'package:lms_touch_and_solve/Presentation/Auth/Pages/login_page.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_event.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_state.dart';
import 'package:lms_touch_and_solve/Presentation/Student/Pages/student_home_page.dart';
import 'package:lms_touch_and_solve/Presentation/Student/Widgets/course_card.dart';

import '../helpers/fakes.dart';
import '../helpers/test_harness.dart';

void main() {
  group('Golden — CourseCard', () {
    testWidgets('available (paid) course', (tester) async {
      await pumpForGolden(
        tester,
        wrapWithApp(
          Center(
            child: CourseCard(
              course: buildCourse(
                title: 'Flutter Fundamentals',
                instructorName: 'Jane Doe',
                price: 1500,
                totalLessons: 24,
              ),
              onTap: () {},
            ),
          ),
        ),
        size: const Size(260, 300),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/course_card_paid.png'),
      );
    });

    testWidgets('wishlisted course shows the filled heart', (tester) async {
      await pumpForGolden(
        tester,
        wrapWithApp(
          Center(
            child: CourseCard(
              course: buildCourse(
                title: 'Flutter Fundamentals',
                instructorName: 'Jane Doe',
                price: 1500,
                isWishlisted: true,
              ),
              onTap: () {},
              onWishlistToggle: () {},
            ),
          ),
        ),
        size: const Size(260, 300),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/course_card_wishlisted.png'),
      );
    });

    testWidgets('upcoming course shows the COMING SOON badge', (tester) async {
      await pumpForGolden(
        tester,
        wrapWithApp(
          Center(
            child: CourseCard(
              course: buildCourse(
                title: 'Advanced Dart',
                instructorName: 'Jane Doe',
                price: 0,
                isUpcoming: true,
              ),
              onTap: () {},
            ),
          ),
        ),
        size: const Size(260, 300),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/course_card_coming_soon.png'),
      );
    });
  });

  group('Golden — Login view', () {
    testWidgets('login page renders consistently', (tester) async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());
      addTearDown(bloc.close);

      await pumpForGolden(
        tester,
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: testTheme(),
          // The route table is irrelevant here; LoginPage is the home widget.
          home: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const LoginPage(),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_page.png'),
      );
    });

    testWidgets('login page in the loading state', (tester) async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());
      addTearDown(bloc.close);

      await pumpForGolden(
        tester,
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: testTheme(),
          home: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const LoginPage(),
          ),
        ),
      );

      bloc.emit(AuthLoading());
      await tester.pump();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_page_loading.png'),
      );
    });
  });

  group('Golden — Student Dashboard', () {
    testWidgets('dashboard with enrolled and recommended courses',
        (tester) async {
      final repo = FakeCourseRepository(
        enrolled: [
          buildCourse(id: 'e1', title: 'My Enrolled Course', totalLessons: 8),
        ],
        courses: [
          buildCourse(id: 'c1', title: 'Flutter Fundamentals', price: 1500),
          buildCourse(id: 'c2', title: 'Dart Deep Dive', price: 900),
        ],
      );
      final bloc = CourseBloc(courseRepository: repo);
      addTearDown(bloc.close);

      // Seed the bloc so the dashboard renders its loaded state deterministically.
      bloc.add(LoadMyEnrollments());
      bloc.add(LoadAllCourses());
      await bloc.stream.firstWhere(
        (s) => s.allCoursesStatus == CourseStatus.loaded,
      );

      await pumpForGolden(
        tester,
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: testTheme(),
          home: BlocProvider<CourseBloc>.value(
            value: bloc,
            child: const StudentHomePage(),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/student_dashboard.png'),
      );
    });

    testWidgets('dashboard empty state', (tester) async {
      final bloc = CourseBloc(courseRepository: FakeCourseRepository());
      addTearDown(bloc.close);

      bloc.add(LoadMyEnrollments());
      bloc.add(LoadAllCourses());
      await bloc.stream.firstWhere(
        (s) => s.allCoursesStatus == CourseStatus.loaded,
      );

      await pumpForGolden(
        tester,
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: testTheme(),
          home: BlocProvider<CourseBloc>.value(
            value: bloc,
            child: const StudentHomePage(),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/student_dashboard_empty.png'),
      );
    });
  });
}
