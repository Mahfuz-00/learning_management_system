// Data-source tests: HTTP layer with a mocked Dio adapter.
//
// A fake [HttpClientAdapter] intercepts every request and returns a canned
// Response, so the data sources are exercised end to end (URL, method, body,
// parsing, error mapping) without any real socket.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Core/Constants/api_routes.dart';
import 'package:lms_touch_and_solve/Core/Error/exceptions.dart';
import 'package:lms_touch_and_solve/Data/DataSources/auth_remote_data_source.dart';
import 'package:lms_touch_and_solve/Data/DataSources/course_remote_data_source.dart';

/// Records the last request and returns a scripted response.
class _MockAdapter implements HttpClientAdapter {
  _MockAdapter({
    this.statusCode = 200,
    Object? body,
    this.headers = const {},
    this.throwError,
  }) : _body = body;

  int statusCode;
  final Object? _body;
  final Map<String, List<String>> headers;

  /// When set, the adapter throws this (simulating a transport failure).
  DioException? throwError;

  RequestOptions? lastRequest;
  String? lastBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      lastBody = utf8.decode(chunks.expand((c) => c).toList());
    }
    if (throwError != null) throw throwError!;

    final encoded = _body == null ? '' : jsonEncode(_body);
    return ResponseBody.fromString(
      encoded,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_MockAdapter adapter, {String baseUrl = 'https://api.test/api/'}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  dio.httpClientAdapter = adapter;
  return dio;
}

/// Builds a DioException as Dio would raise it for a bad response.
DioException _badResponse(
  int status, {
  Object? data,
  Map<String, List<String>>? headers,
  String path = 'test',
}) {
  final options = RequestOptions(path: path);
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: options,
      statusCode: status,
      data: data,
      headers: headers == null ? null : Headers.fromMap(headers),
    ),
  );
}

void main() {
  group('AuthRemoteDataSourceImpl', () {
    test('login POSTs credentials and unwraps the user', () async {
      final adapter = _MockAdapter(body: {
        'data': {'userId': 'u1', 'email': 'a@b.com', 'fullName': 'Ali', 'role': 0},
      });
      final ds = AuthRemoteDataSourceImpl(dio: _dioWith(adapter));

      final user = await ds.login('a@b.com', 'secret');

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.path, ApiRoutes.login);
      expect(adapter.lastBody, contains('a@b.com'));
      expect(user.id, 'u1');
      expect(user.fullName, 'Ali');
    });

    test('login tolerates a bare (unwrapped) user object', () async {
      final adapter = _MockAdapter(body: {'userId': 'u2', 'fullName': 'Sara'});
      final ds = AuthRemoteDataSourceImpl(dio: _dioWith(adapter));

      expect((await ds.login('x', 'y')).id, 'u2');
    });

    test('a 401 on the login route maps to AuthException with server text',
        () async {
      final adapter = _MockAdapter()
        ..throwError = _badResponse(
          401,
          data: {'message': 'Invalid email or password.'},
          path: ApiRoutes.login,
        );
      final ds = AuthRemoteDataSourceImpl(dio: _dioWith(adapter));

      await expectLater(
        ds.login('a@b.com', 'wrong'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Invalid email or password.',
          ),
        ),
      );
    });

    test('a 429 maps to ServerException carrying Retry-After', () async {
      final adapter = _MockAdapter()
        ..throwError = _badResponse(
          429,
          data: {'message': 'Too many attempts'},
          headers: {'retry-after': ['90']},
        );
      final ds = AuthRemoteDataSourceImpl(dio: _dioWith(adapter));

      await expectLater(
        ds.login('a@b.com', 'x'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 429)
              .having((e) => e.retryAfterSeconds, 'retryAfterSeconds', 90),
        ),
      );
    });

    test('a timeout maps to NetworkException', () async {
      final adapter = _MockAdapter()
        ..throwError = DioException(
          requestOptions: RequestOptions(path: 'x'),
          type: DioExceptionType.connectionTimeout,
        );
      final ds = AuthRemoteDataSourceImpl(dio: _dioWith(adapter));

      await expectLater(ds.login('a', 'b'), throwsA(isA<NetworkException>()));
    });

    test('getProfile GETs the profile route', () async {
      final adapter = _MockAdapter(body: {'userId': 'u1', 'fullName': 'Ali'});
      final ds = AuthRemoteDataSourceImpl(dio: _dioWith(adapter));

      await ds.getProfile();

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.path, ApiRoutes.profile);
    });

    test('resetPassword uses PUT (the spec verb)', () async {
      final adapter = _MockAdapter(body: {});
      final ds = AuthRemoteDataSourceImpl(dio: _dioWith(adapter));

      await ds.resetPassword('a@b.com', '123456', 'newPass');

      expect(adapter.lastRequest!.method, 'PUT');
      expect(adapter.lastRequest!.path, ApiRoutes.passwordResetReset);
    });

    test('verifyEmail POSTs email + otp', () async {
      final adapter = _MockAdapter(body: {});
      final ds = AuthRemoteDataSourceImpl(dio: _dioWith(adapter));

      await ds.verifyEmail('a@b.com', '999999');

      expect(adapter.lastBody, allOf(contains('a@b.com'), contains('999999')));
    });

    test('resolveInvite returns the unwrapped map', () async {
      final adapter = _MockAdapter(body: {
        'data': {'teacherEmail': 't@x.com'}
      });
      final ds = AuthRemoteDataSourceImpl(dio: _dioWith(adapter));

      expect((await ds.resolveInvite('tok'))['teacherEmail'], 't@x.com');
    });
  });

  group('CourseRemoteDataSourceImpl', () {
    test('getAllCourses parses a data envelope', () async {
      final adapter = _MockAdapter(body: {
        'data': [
          {'id': 'c1', 'title': 'Flutter', 'price': 1000},
          {'id': 'c2', 'title': 'Dart', 'price': 500},
        ],
      });
      final ds = CourseRemoteDataSourceImpl(dio: _dioWith(adapter));

      final courses = await ds.getAllCourses();

      expect(courses, hasLength(2));
      expect(courses.first.title, 'Flutter');
      expect(adapter.lastRequest!.method, 'GET');
    });

    test('getAllCourses tolerates a bare list', () async {
      final adapter = _MockAdapter(body: [
        {'id': 'c1', 'title': 'Only', 'price': 0},
      ]);
      final ds = CourseRemoteDataSourceImpl(dio: _dioWith(adapter));

      expect((await ds.getAllCourses()).single.id, 'c1');
    });

    test('getAllCourses returns empty on a non-list payload', () async {
      final adapter = _MockAdapter(body: {'unexpected': true});
      final ds = CourseRemoteDataSourceImpl(dio: _dioWith(adapter));

      expect(await ds.getAllCourses(), isEmpty);
    });

    test('toggleWishlist POSTs to the course-scoped route', () async {
      final adapter = _MockAdapter(body: {});
      final ds = CourseRemoteDataSourceImpl(dio: _dioWith(adapter));

      await ds.toggleWishlist('c1', 'u1');

      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastRequest!.path, ApiRoutes.toggleWishlist('c1', 'u1'));
    });

    test('getMyWishlist parses the user wishlist', () async {
      final adapter = _MockAdapter(body: {
        'data': [
          {'id': 'c1', 'title': 'Saved', 'price': 0, 'isWishlisted': true},
        ],
      });
      final ds = CourseRemoteDataSourceImpl(dio: _dioWith(adapter));

      final list = await ds.getMyWishlist('u1');

      expect(list.single.isWishlisted, isTrue);
      expect(adapter.lastRequest!.path, ApiRoutes.wishlist('u1'));
    });

    test('a 404 maps to the "no longer available" ServerException', () async {
      final adapter = _MockAdapter()..throwError = _badResponse(404);
      final ds = CourseRemoteDataSourceImpl(dio: _dioWith(adapter));

      await expectLater(
        ds.getCourseById('gone'),
        throwsA(
          isA<ServerException>().having((e) => e.statusCode, 'status', 404),
        ),
      );
    });

    test('a 500 maps to the busy-server message', () async {
      final adapter = _MockAdapter()..throwError = _badResponse(500);
      final ds = CourseRemoteDataSourceImpl(dio: _dioWith(adapter));

      await expectLater(
        ds.getAllCourses(),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'status', 500)
              .having((e) => e.message.toLowerCase(), 'message', contains('busy')),
        ),
      );
    });

    test('the store endpoint parses items', () async {
      final adapter = _MockAdapter(body: {
        'data': [
          {'id': 's1', 'title': 'Book', 'price': 500},
        ],
      });
      final ds = CourseRemoteDataSourceImpl(dio: _dioWith(adapter));

      final items = await ds.getStoreItems();
      expect(items.single.title, 'Book');
    });

    test('deleteStoreItem issues a DELETE', () async {
      final adapter = _MockAdapter(body: {});
      final ds = CourseRemoteDataSourceImpl(dio: _dioWith(adapter));

      await ds.deleteStoreItem('s1');

      expect(adapter.lastRequest!.method, 'DELETE');
    });
  });
}
