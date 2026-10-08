// Widget tests for reusable presentational components across the app.
//
// These widgets are pure (no BLoC), so each is rendered directly and asserted on
// what the user sees and what callbacks fire.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Presentation/Course/Widgets/hub_card.dart';
import 'package:lms_touch_and_solve/Presentation/Teacher/Widgets/teacher_course_card.dart';
import 'package:lms_touch_and_solve/Presentation/Teacher/Widgets/teacher_stat_card.dart';

import '../helpers/test_harness.dart';

void main() {
  group('TeacherStatCard', () {
    testWidgets('renders the value, title and icon', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          const TeacherStatCard(
            title: 'Total Students',
            value: '142',
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
      );

      expect(find.text('142'), findsOneWidget);
      expect(find.text('Total Students'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('renders distinct content for different stats', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          const Row(
            children: [
              Expanded(
                child: TeacherStatCard(
                  title: 'Courses',
                  value: '5',
                  icon: Icons.book,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: TeacherStatCard(
                  title: 'Revenue',
                  value: '৳5000',
                  icon: Icons.payments,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('৳5000'), findsOneWidget);
    });
  });

  group('HubCard', () {
    Widget host({
      int? badgeCount,
      VoidCallback? onTap,
    }) {
      return wrapWithApp(
        SizedBox(
          width: 200,
          height: 160,
          child: HubCard(
            icon: Icons.play_circle,
            title: 'Live Class',
            subtitle: 'Next: Monday 7pm',
            color: Colors.blue,
            onTap: onTap ?? () {},
            badgeCount: badgeCount,
          ),
        ),
      );
    }

    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(host());
      expect(find.text('Live Class'), findsOneWidget);
      expect(find.text('Next: Monday 7pm'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle), findsOneWidget);
    });

    testWidgets('tapping fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(onTap: () => taps++));

      await tester.tap(find.text('Live Class'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('shows a badge when the count is positive', (tester) async {
      await tester.pumpWidget(host(badgeCount: 3));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('hides the badge when the count is null or zero', (tester) async {
      await tester.pumpWidget(host(badgeCount: 0));
      expect(find.text('0'), findsNothing);

      await tester.pumpWidget(host());
      expect(find.text('0'), findsNothing);
    });
  });

  group('TeacherCourseCard', () {
    testWidgets('renders title, lesson count and progress', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          TeacherCourseCard(
            course: buildCourse(title: 'Advanced Dart', totalLessons: 8),
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Advanced Dart'), findsOneWidget);
      expect(find.text('8 Lessons'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('tapping the card fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrapWithApp(
          TeacherCourseCard(
            course: buildCourse(title: 'Tap Me'),
            onTap: () => taps++,
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('shows a chevron affordance', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          TeacherCourseCard(course: buildCourse(), onTap: () {}),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
