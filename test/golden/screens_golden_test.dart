// Golden (visual regression) tests — screens beyond the login/dashboard set:
// student profile, notifications and announcements.
//
// Same determinism rules as golden_test.dart: fixed surface, real font, no
// network. See test/README.md for the regeneration workflow.
//
// Regenerate after an intentional UI change:
//
//     flutter test --update-goldens test/golden

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/auth_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Auth/Bloc/auth_state.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Notifications/Bloc/notification_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Notifications/Bloc/notification_event.dart';
import 'package:lms_touch_and_solve/Presentation/Notifications/Bloc/notification_state.dart';
import 'package:lms_touch_and_solve/Presentation/Notifications/Pages/announcements_page.dart';
import 'package:lms_touch_and_solve/Presentation/Notifications/Pages/notifications_page.dart';
import 'package:lms_touch_and_solve/Presentation/Student/Pages/student_profile_page.dart';
import 'package:lms_touch_and_solve/Presentation/Student/Pages/student_wishlist_page.dart';

import '../helpers/fakes.dart';
import '../helpers/test_harness.dart';

void main() {
  group('Golden — Student profile', () {
    testWidgets('profile screen for a signed-in student', (tester) async {
      final bloc = AuthBloc(authRepository: FakeAuthRepository());
      addTearDown(bloc.close);
      bloc.emit(Authenticated(
        buildUser(fullName: 'Test Student', email: 'student@nirvoor.com'),
      ));

      await pumpForGolden(
        tester,
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: testTheme(),
          home: BlocProvider<AuthBloc>.value(
            value: bloc,
            child: const StudentProfilePage(),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/student_profile.png'),
      );
    });
  });

  group('Golden — Wishlist', () {
    testWidgets('empty wishlist state', (tester) async {
      final bloc = CourseBloc(courseRepository: FakeCourseRepository());
      addTearDown(bloc.close);

      await pumpForGolden(
        tester,
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: testTheme(),
          home: BlocProvider<CourseBloc>.value(
            value: bloc,
            child: const StudentWishlistPage(),
          ),
        ),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wishlist_empty.png'),
      );
    });
  });

  group('Golden — Notifications', () {
    Widget host(NotificationBloc bloc, Widget child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: testTheme(),
          home: BlocProvider<NotificationBloc>.value(value: bloc, child: child),
        );

    testWidgets('notifications list with unread items', (tester) async {
      final repo = FakeLearningRepository(
        notificationsResult: Right([
          buildNotification(id: 'n1', title: 'New lesson added'),
          buildNotification(id: 'n2', title: 'Live class tomorrow', isRead: true),
        ]),
        unreadCountResult: const Right(1),
      );
      final bloc = NotificationBloc(repository: repo);
      addTearDown(bloc.close);

      await pumpForGolden(
        tester,
        host(bloc, const NotificationsPage()),
      );
      // Let initState's LoadNotifications settle before the snapshot.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/notifications_page.png'),
      );
    });

    testWidgets('notifications empty state', (tester) async {
      final bloc = NotificationBloc(repository: FakeLearningRepository());
      addTearDown(bloc.close);

      await pumpForGolden(
        tester,
        host(bloc, const NotificationsPage()),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/notifications_empty.png'),
      );
    });

    testWidgets('announcements page', (tester) async {
      final bloc = NotificationBloc(repository: FakeLearningRepository());
      addTearDown(bloc.close);

      await pumpForGolden(
        tester,
        host(bloc, const AnnouncementsPage()),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/announcements_page.png'),
      );
    });
  });
}
