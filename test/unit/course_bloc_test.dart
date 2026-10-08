// Unit tests for CourseBloc — wishlist state management.
//
// Covers the behaviours established when the wishlist was fixed:
//   * an optimistic, single-item flip with no full catalogue reload;
//   * rollback + error reporting when the request fails;
//   * an in-flight guard against double taps;
//   * hydration: the wishlist re-marks the catalogue after a refresh.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_event.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_state.dart';

import '../helpers/fakes.dart';
import '../helpers/test_harness.dart';

void main() {
  Future<CourseBloc> blocWithCatalogue(
    FakeCourseRepository repo, {
    List<String> wishlistIds = const [],
  }) async {
    repo.wishlist = wishlistIds
        .map((id) => buildCourse(id: id, isWishlisted: true))
        .toList();
    final bloc = CourseBloc(courseRepository: repo);
    addTearDown(bloc.close);
    bloc.add(LoadAllCourses());
    await bloc.stream
        .firstWhere((s) => s.allCoursesStatus == CourseStatus.loaded);
    if (wishlistIds.isNotEmpty) {
      bloc.add(const LoadMyWishlist());
      await bloc.stream
          .firstWhere((s) => s.wishlistStatus == CourseStatus.loaded);
    }
    return bloc;
  }

  group('CourseBloc — catalogue', () {
    test('loads courses and reports an error without throwing', () async {
      final repo = FakeCourseRepository(courses: [buildCourse(id: 'a')]);
      final bloc = await blocWithCatalogue(repo);

      expect(bloc.state.allCourses, hasLength(1));
      expect(bloc.state.allCoursesStatus, CourseStatus.loaded);
    });

    test('a failed load surfaces the failure message', () async {
      final repo = FakeCourseRepository(failGetAll: true);
      final bloc = CourseBloc(courseRepository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadAllCourses());
      final state = await bloc.stream
          .firstWhere((s) => s.allCoursesStatus == CourseStatus.error);

      expect(state.errorMessage, isNotNull);
    });
  });

  group('CourseBloc — wishlist toggle', () {
    test('optimistically flips the heart without reloading the catalogue',
        () async {
      final repo = FakeCourseRepository(
        courses: [buildCourse(id: 'a'), buildCourse(id: 'b')],
      );
      final bloc = await blocWithCatalogue(repo);
      final callsAfterLoad = repo.getAllCoursesCalls;

      bloc.add(ToggleWishlistEvent('a'));

      // The very first emission after the tap must already show the flip.
      final optimistic = await bloc.stream.firstWhere(
        (s) => s.allCourses.firstWhere((c) => c.id == 'a').isWishlisted,
      );
      expect(optimistic.wishlistToggling, contains('a'));

      await bloc.stream.firstWhere((s) => s.wishlistToggling.isEmpty);

      expect(
        bloc.state.allCourses.firstWhere((c) => c.id == 'a').isWishlisted,
        isTrue,
      );
      expect(
        bloc.state.allCourses.firstWhere((c) => c.id == 'b').isWishlisted,
        isFalse,
      );
      // No full-screen reload: the catalogue was fetched exactly once.
      expect(repo.getAllCoursesCalls, callsAfterLoad);
      expect(bloc.state.wishlistToggleError, isNull);
    });

    test('rolls the heart back and reports the error when the request fails',
        () async {
      final repo = FakeCourseRepository(
        courses: [buildCourse(id: 'a')],
        failToggle: true,
      );
      final bloc = await blocWithCatalogue(repo);

      bloc.add(ToggleWishlistEvent('a'));

      final failed = await bloc.stream
          .firstWhere((s) => s.wishlistToggleError != null);

      expect(
        failed.allCourses.firstWhere((c) => c.id == 'a').isWishlisted,
        isFalse,
        reason: 'the optimistic flip must be reverted',
      );
      expect(failed.wishlistToggling, isNot(contains('a')));
      expect(failed.wishlistToggleError, isNotNull);
    });

    test('ignores a second tap while the first request is in flight', () async {
      final repo = FakeCourseRepository(courses: [buildCourse(id: 'a')]);
      final gate = Completer<void>();
      repo.toggleGate = gate.future;
      final bloc = await blocWithCatalogue(repo);

      bloc.add(ToggleWishlistEvent('a'));
      await bloc.stream.firstWhere((s) => s.wishlistToggling.contains('a'));

      bloc.add(ToggleWishlistEvent('a'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(repo.toggleCalls, 1,
          reason: 'the in-flight guard must block the duplicate request');

      gate.complete();
      await bloc.stream.firstWhere((s) => s.wishlistToggling.isEmpty);
    });

    test('toggling a course already in the wishlist removes it locally',
        () async {
      final repo = FakeCourseRepository(
        courses: [buildCourse(id: 'a', isWishlisted: true)],
      );
      final bloc = await blocWithCatalogue(repo, wishlistIds: ['a']);
      expect(bloc.state.wishlist, hasLength(1));

      bloc.add(ToggleWishlistEvent('a'));
      await bloc.stream.firstWhere((s) => s.wishlistToggling.isEmpty);

      expect(bloc.state.wishlist, isEmpty);
      expect(
        bloc.state.allCourses.firstWhere((c) => c.id == 'a').isWishlisted,
        isFalse,
      );
    });
  });

  group('CourseBloc — wishlist hydration after refresh', () {
    test('LoadMyWishlist re-marks the catalogue so hearts survive a refetch',
        () async {
      // Catalogue arrives with isWishlisted = false (the real API shape).
      final repo = FakeCourseRepository(
        courses: [buildCourse(id: 'a'), buildCourse(id: 'b')],
      );
      final bloc = await blocWithCatalogue(repo, wishlistIds: ['b']);

      bloc.add(const LoadMyWishlist());
      final state = await bloc.stream.firstWhere(
        (s) => s.wishlistStatus == CourseStatus.loaded,
      );

      expect(
        state.allCourses.firstWhere((c) => c.id == 'b').isWishlisted,
        isTrue,
        reason: 'course b is in the wishlist and must stay marked',
      );
      expect(
        state.allCourses.firstWhere((c) => c.id == 'a').isWishlisted,
        isFalse,
      );
      expect(state.wishlist, hasLength(1));
    });
  });
}
