// Shared helpers for the whole test suite.
//
// Kept in one place so unit, widget and golden tests build the app the same way
// and so the golden environment is configured identically everywhere.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Domain/Entities/course_entity.dart';
import 'package:lms_touch_and_solve/Domain/Entities/user_entity.dart';

/// Logical surface size used for golden tests (iPhone 14).
const Size kGoldenSize = Size(390, 844);

/// ----------------------------------------------------------------------------
/// Test data factories
/// ----------------------------------------------------------------------------

CourseEntity buildCourse({
  String id = 'c1',
  String title = 'Flutter Fundamentals',
  double price = 1000,
  String? instructorName = 'Jane Doe',
  String? thumbnail,
  bool isWishlisted = false,
  bool isEnrolled = false,
  bool isUpcoming = false,
  int totalLessons = 12,
  double? rating,
}) {
  return CourseEntity(
    id: id,
    title: title,
    price: price,
    instructorName: instructorName,
    thumbnail: thumbnail,
    isWishlisted: isWishlisted,
    isEnrolled: isEnrolled,
    isUpcoming: isUpcoming,
    totalLessons: totalLessons,
    rating: rating,
  );
}

UserEntity buildUser({
  String id = 'u1',
  String email = 'student@nirvoor.com',
  String fullName = 'Test Student',
  int role = 0,
}) {
  return UserEntity(id: id, email: email, fullName: fullName, role: role);
}

/// ----------------------------------------------------------------------------
/// Widget-test harness
/// ----------------------------------------------------------------------------

/// Material theme matching the app's real colours (AppColors.primaryBlue) with a
/// fixed font, so text metrics and colours are stable in widget/golden tests.
ThemeData testTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2C76A7),
      primary: const Color(0xFF2C76A7),
      secondary: const Color(0xFF81B848),
      error: const Color(0xFFFF5757),
    ),
    fontFamily: 'Roboto',
  );
}

/// Wraps [child] in a MaterialApp/Scaffold with the app's theme so widget tests
/// render realistic text styles and spacing.
Widget wrapWithApp(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme ?? testTheme(),
    home: Scaffold(body: child),
  );
}

/// ----------------------------------------------------------------------------
/// Golden-test utilities
/// ----------------------------------------------------------------------------

/// Pins surface size and device pixel ratio for a deterministic golden render,
/// and restores them afterwards. Call at the start of a golden test.
void prepareGolden(
  WidgetTester tester, {
  Size size = kGoldenSize,
  double devicePixelRatio = 1.0,
}) {
  tester.view.physicalSize = size * devicePixelRatio;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Renders [widget] into a fixed-size surface and settles animations.
///
/// Used by golden tests: the surface is pinned so the produced PNG does not
/// depend on the host window size.
Future<void> pumpForGolden(
  WidgetTester tester,
  Widget widget, {
  Size size = kGoldenSize,
  double devicePixelRatio = 1.0,
}) async {
  prepareGolden(tester, size: size, devicePixelRatio: devicePixelRatio);
  await tester.pumpWidget(widget);
  // Two pumps: first lays out, second lets implicit animations (e.g. AppBar
  // elevation, image placeholders) reach their resting frame.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}
