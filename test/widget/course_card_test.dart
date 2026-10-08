// Widget tests for CourseCard — rendering and user interaction.
//
// CourseCard shows a thumbnail (AppNetworkImage), a wishlist heart, a status
// badge and pricing. The tests use a null thumbnail so AppNetworkImage renders
// its offline placeholder deterministically.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Presentation/Student/Widgets/course_card.dart';

import '../helpers/test_harness.dart';

void main() {
  group('CourseCard — rendering', () {
    testWidgets('shows the title, instructor and lesson count', (tester) async {
      final course = buildCourse(
        title: 'Flutter Fundamentals',
        instructorName: 'Jane Doe',
        totalLessons: 24,
        price: 1000,
      );

      await tester.pumpWidget(
        wrapWithApp(CourseCard(course: course, onTap: () {})),
      );

      expect(find.text('Flutter Fundamentals'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('24 Lessons'), findsOneWidget);
      // Price is formatted with the Taka sign and no decimals.
      expect(find.text('৳1000'), findsOneWidget);
    });

    testWidgets('a free course shows "Free" instead of a price', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(CourseCard(course: buildCourse(price: 0), onTap: () {})),
      );

      expect(find.text('Free'), findsOneWidget);
      expect(find.text('৳0'), findsNothing);
    });

    testWidgets('an upcoming course shows the COMING SOON badge, never a price',
        (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          CourseCard(course: buildCourse(isUpcoming: true, price: 500), onTap: () {}),
        ),
      );

      expect(find.text('COMING SOON'), findsOneWidget);
      expect(find.text('Coming soon'), findsOneWidget);
      // Rule 3: an upcoming course is never priced and never says "Free".
      expect(find.text('Free'), findsNothing);
      expect(find.text('৳500'), findsNothing);
    });

    testWidgets('an enrolled course shows the ENROLLED badge', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          CourseCard(course: buildCourse(isEnrolled: true), onTap: () {}),
        ),
      );

      expect(find.text('ENROLLED'), findsOneWidget);
    });

    testWidgets('a fallback instructor name is shown when none is provided',
        (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          CourseCard(course: buildCourse(instructorName: null), onTap: () {}),
        ),
      );

      expect(find.text('Instructor'), findsOneWidget);
    });
  });

  group('CourseCard — wishlist heart', () {
    testWidgets('shows a filled heart when wishlisted and an outline otherwise',
        (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          CourseCard(course: buildCourse(isWishlisted: true), onTap: () {}),
        ),
      );
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      await tester.pumpWidget(
        wrapWithApp(
          CourseCard(course: buildCourse(isWishlisted: false), onTap: () {}),
        ),
      );
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('tapping the heart fires onWishlistToggle', (tester) async {
      var toggles = 0;
      await tester.pumpWidget(
        wrapWithApp(
          CourseCard(
            course: buildCourse(),
            onTap: () {},
            onWishlistToggle: () => toggles++,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(toggles, 1);
    });
  });

  group('CourseCard — card tap', () {
    testWidgets('tapping the card body fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrapWithApp(
          CourseCard(
            course: buildCourse(title: 'Tap Me'),
            onTap: () => taps++,
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('tapping the heart does not also open the course', (tester) async {
      var cardTaps = 0;
      var heartTaps = 0;
      await tester.pumpWidget(
        wrapWithApp(
          CourseCard(
            course: buildCourse(),
            onTap: () => cardTaps++,
            onWishlistToggle: () => heartTaps++,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(heartTaps, 1);
      // The heart is a child GestureDetector; tapping it must not bubble up.
      expect(cardTaps, 0);
    });
  });
}
