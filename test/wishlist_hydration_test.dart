// Verifies wishlist persistence across refreshes.
//
// The main catalogue endpoint (`Course/GetAll`) does NOT return an
// `isWishlisted` field (verified against the live API), so on every refresh
// every course came back with the flag reset to false and the heart icon
// vanished. CourseRepositoryImpl now hydrates the catalogue by cross-referencing
// the signed-in user's wishlist. These tests lock that behaviour in.

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Core/Error/exceptions.dart';
import 'package:lms_touch_and_solve/Data/DataSources/auth_local_data_source.dart';
import 'package:lms_touch_and_solve/Data/DataSources/course_remote_data_source.dart';
import 'package:lms_touch_and_solve/Data/Models/course_model.dart';
import 'package:lms_touch_and_solve/Data/Models/user_model.dart';
import 'package:lms_touch_and_solve/Data/Repositories/course_repository_impl.dart';
import 'package:lms_touch_and_solve/Domain/Entities/course_entity.dart';

CourseModel _course(String id, {bool wishlisted = false}) => CourseModel(
      id: id,
      title: 'Course $id',
      price: 100,
      isWishlisted: wishlisted,
    );

/// Remote source stub: only the catalogue + wishlist reads are implemented.
class _FakeRemote implements CourseRemoteDataSource {
  _FakeRemote({required this.courses, required this.wishlist});

  final List<CourseModel> courses;
  final List<CourseModel> wishlist;

  @override
  Future<List<CourseModel>> getAllCourses() async => courses;

  @override
  Future<List<CourseModel>> getMyWishlist(String userId) async => wishlist;

  @override
  Future<List<CourseModel>> getMyEnrollments() async => courses;

  @override
  Future<CourseModel> getCourseById(String id) async =>
      courses.firstWhere((c) => c.id == id);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} not used in this test');
}

/// Local source stub returning a fixed signed-in user.
class _FakeLocal implements AuthLocalDataSource {
  _FakeLocal({this.user});

  final UserModel? user;

  @override
  Future<UserModel?> getUser() async => user;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName} not used in this test');
}

void main() {
  final user = const UserModel(
    id: 'u1',
    email: 'a@b.com',
    fullName: 'Test User',
    role: 0,
  );

  group('CourseRepositoryImpl wishlist hydration', () {
    test('marks catalogue courses that exist in the wishlist', () async {
      final repo = CourseRepositoryImpl(
        remoteDataSource: _FakeRemote(
          // Catalogue comes back with isWishlisted = false (the real API shape).
          courses: [_course('a'), _course('b'), _course('c')],
          wishlist: [_course('b', wishlisted: true)],
        ),
        localDataSource: _FakeLocal(user: user),
      );

      final result = await repo.getAllCourses();
      final courses = result.getOrElse(() => throw StateError('expected Right'));

      expect(courses.firstWhere((c) => c.id == 'b').isWishlisted, isTrue,
          reason: 'course b is in the wishlist and must survive the refresh');
      expect(courses.firstWhere((c) => c.id == 'a').isWishlisted, isFalse);
      expect(courses.firstWhere((c) => c.id == 'c').isWishlisted, isFalse);
    });

    test('leaves the catalogue intact when the user is not signed in', () async {
      final repo = CourseRepositoryImpl(
        remoteDataSource: _FakeRemote(
          courses: [_course('a')],
          wishlist: [_course('a', wishlisted: true)],
        ),
        localDataSource: _FakeLocal(user: null),
      );

      final result = await repo.getAllCourses();
      final courses = result.getOrElse(() => throw StateError('expected Right'));
      expect(courses.single.isWishlisted, isFalse);
    });

    test('returns the catalogue even if the wishlist lookup fails', () async {
      final repo = CourseRepositoryImpl(
        remoteDataSource: _ThrowingWishlistRemote(courses: [_course('a')]),
        localDataSource: _FakeLocal(user: user),
      );

      final result = await repo.getAllCourses();
      final courses = result.getOrElse(() => throw StateError('expected Right'));
      expect(courses.single.id, 'a',
          reason: 'a wishlist failure must not take down the catalogue');
    });

    test('hydrates a single course fetched by id', () async {
      final repo = CourseRepositoryImpl(
        remoteDataSource: _FakeRemote(
          courses: [_course('a'), _course('b')],
          wishlist: [_course('b', wishlisted: true)],
        ),
        localDataSource: _FakeLocal(user: user),
      );

      final result = await repo.getCourseById('b');
      final course = result.getOrElse(() => throw StateError('expected Right'));
      expect(course.isWishlisted, isTrue);
    });

    test('is idempotent — hydrating an already-marked course is a no-op',
        () async {
      final repo = CourseRepositoryImpl(
        remoteDataSource: _FakeRemote(
          courses: [_course('a', wishlisted: true)],
          wishlist: [_course('a', wishlisted: true)],
        ),
        localDataSource: _FakeLocal(user: user),
      );

      final result = await repo.getAllCourses();
      final courses = result.getOrElse(() => throw StateError('expected Right'));
      expect(courses.single.isWishlisted, isTrue);
    });
  });
}

/// Remote stub whose wishlist call throws, to prove the fallback path.
class _ThrowingWishlistRemote extends _FakeRemote {
  _ThrowingWishlistRemote({required super.courses})
      : super(wishlist: const []);

  @override
  Future<List<CourseModel>> getMyWishlist(String userId) async {
    throw const ServerException(message: 'wishlist endpoint down');
  }
}
