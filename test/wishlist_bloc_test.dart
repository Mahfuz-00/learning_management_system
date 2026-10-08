// Verifies the wishlist toggle behaves as an optimistic, single-item update:
//   1. the heart flips immediately, without a full catalogue reload;
//   2. a failed request rolls the heart back and reports the error;
//   3. a second tap while the first is in flight is ignored.
//
// The real CourseBloc is driven with a fake CourseRepository, so no network is
// touched. Only the wishlist-related methods are implemented; everything else
// throws (the bloc never calls them in these scenarios).

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Core/Error/failures.dart';
import 'package:lms_touch_and_solve/Domain/Entities/course_entity.dart';
import 'package:lms_touch_and_solve/Domain/Repositories/course_repository.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_bloc.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_event.dart';
import 'package:lms_touch_and_solve/Presentation/Course/Bloc/course_state.dart';

CourseEntity _course(String id, {bool wishlisted = false}) => CourseEntity(
      id: id,
      title: 'Course $id',
      price: 100,
      isWishlisted: wishlisted,
    );

/// Minimal repository: records whether the catalogue was reloaded and lets the
/// test choose the toggle outcome.
class _FakeRepo implements CourseRepository {
  _FakeRepo({this.failToggle = false, this.courses = const []});

  final bool failToggle;
  final List<CourseEntity> courses;

  int getAllCoursesCalls = 0;
  int toggleCalls = 0;
  Completer<void>? toggleGate;

  @override
  Future<Either<Failure, List<CourseEntity>>> getAllCourses() async {
    getAllCoursesCalls++;
    return Right(courses);
  }

  @override
  Future<Either<Failure, Unit>> toggleWishlist(String courseId) async {
    toggleCalls++;
    if (toggleGate != null) await toggleGate!.future;
    if (failToggle) {
      return const Left(ServerFailure('Network error'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getMyWishlist() async =>
      const Right([]);

  // Anything not exercised by the wishlist flow is unsupported here.
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} not used in this test');
}

void main() {
  group('CourseBloc wishlist toggle', () {
    test('optimistically flips the heart without reloading the catalogue',
        () async {
      final repo = _FakeRepo(
        courses: [_course('a'), _course('b')],
      );
      final bloc = CourseBloc(courseRepository: repo);
      addTearDown(bloc.close);

      // Seed the catalogue exactly once.
      bloc.add(LoadAllCourses());
      await bloc.stream.firstWhere((s) => s.allCoursesStatus == CourseStatus.loaded);
      final callsAfterLoad = repo.getAllCoursesCalls;

      bloc.add(ToggleWishlistEvent('a'));

      // First emission after the tap must already show the flipped icon.
      final optimistic = await bloc.stream.firstWhere((s) => s.allCourses
          .firstWhere((c) => c.id == 'a')
          .isWishlisted);
      expect(optimistic.wishlistToggling, contains('a'));

      // Let the request complete.
      await bloc.stream.firstWhere((s) => s.wishlistToggling.isEmpty);
      await Future<void>.delayed(Duration.zero);

      final finalState = bloc.state;
      expect(finalState.allCourses.firstWhere((c) => c.id == 'a').isWishlisted,
          isTrue);
      expect(finalState.allCourses.firstWhere((c) => c.id == 'b').isWishlisted,
          isFalse);
      // Crucially: no extra getAllCourses() call — no full-screen reload.
      expect(repo.getAllCoursesCalls, callsAfterLoad);
      expect(finalState.wishlistToggleError, isNull);
    });

    test('rolls the heart back and reports the error when the request fails',
        () async {
      final repo = _FakeRepo(
        failToggle: true,
        courses: [_course('a')],
      );
      final bloc = CourseBloc(courseRepository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadAllCourses());
      await bloc.stream.firstWhere((s) => s.allCoursesStatus == CourseStatus.loaded);

      bloc.add(ToggleWishlistEvent('a'));

      final failed = await bloc.stream.firstWhere(
        (s) => s.wishlistToggleError != null,
      );
      expect(failed.allCourses.firstWhere((c) => c.id == 'a').isWishlisted,
          isFalse);
      expect(failed.wishlistToggling, isNot(contains('a')));
      expect(failed.wishlistToggleError, isNotNull);
    });

    test('ignores a second tap while the first request is still in flight',
        () async {
      final repo = _FakeRepo(courses: [_course('a')]);
      final gate = Completer<void>();
      repo.toggleGate = gate;
      final bloc = CourseBloc(courseRepository: repo);
      addTearDown(bloc.close);

      bloc.add(LoadAllCourses());
      await bloc.stream.firstWhere((s) => s.allCoursesStatus == CourseStatus.loaded);

      bloc.add(ToggleWishlistEvent('a'));
      await bloc.stream.firstWhere((s) => s.wishlistToggling.contains('a'));
      bloc.add(ToggleWishlistEvent('a'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(repo.toggleCalls, 1,
          reason: 'the in-flight guard must prevent a second request');

      gate.complete();
      await bloc.stream.firstWhere((s) => s.wishlistToggling.isEmpty);
    });
  });
}
