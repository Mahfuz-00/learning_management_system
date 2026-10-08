// Unit tests for JSON parsing — the layer that has to survive a backend whose
// spec declares almost no response schemas.
//
// CourseModel and JsonUtils must tolerate missing fields, string-encoded
// numbers, and both bare-list and { "data": ... } envelopes.

import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Core/Constants/app_constants.dart';
import 'package:lms_touch_and_solve/Data/Models/course_model.dart';
import 'package:lms_touch_and_solve/Data/Models/json_utils.dart';

void main() {
  group('JsonUtils — coercion', () {
    test('toInt accepts numbers and numeric strings', () {
      expect(JsonUtils.toInt(5), 5);
      expect(JsonUtils.toInt('42'), 42);
      expect(JsonUtils.toInt('nope', fallback: 7), 7);
      expect(JsonUtils.toInt(null, fallback: 3), 3);
    });

    test('toDouble accepts numbers and numeric strings', () {
      expect(JsonUtils.toDouble('4.5'), 4.5);
      expect(JsonUtils.toDouble(2), 2.0);
      expect(JsonUtils.toDouble(null, fallback: 1.5), 1.5);
    });

    test('toBool tolerates common string spellings', () {
      expect(JsonUtils.toBool(true), isTrue);
      expect(JsonUtils.toBool('true'), isTrue);
      expect(JsonUtils.toBool('1'), isTrue);
      expect(JsonUtils.toBool('yes'), isTrue);
      expect(JsonUtils.toBool('false'), isFalse);
      expect(JsonUtils.toBool('0'), isFalse);
      expect(JsonUtils.toBool(null), isFalse);
    });

    test('toDate parses ISO strings and ignores junk', () {
      expect(JsonUtils.toDate('2026-01-15T10:00:00'), DateTime(2026, 1, 15, 10));
      expect(JsonUtils.toDate('not-a-date'), isNull);
      expect(JsonUtils.toDate(null), isNull);
    });

    test('unwrapList handles bare lists and envelopes', () {
      expect(
        JsonUtils.unwrapList([
          {'a': 1},
        ]),
        hasLength(1),
      );
      expect(JsonUtils.unwrapList({'data': [1, 2]}), hasLength(2));
      expect(JsonUtils.unwrapList({'items': [1]}), hasLength(1));
      expect(JsonUtils.unwrapList('garbage'), isEmpty);
    });

    test('unwrapMap handles nested data and root maps', () {
      expect(JsonUtils.unwrapMap({'data': {'x': 1}})['x'], 1);
      expect(JsonUtils.unwrapMap({'x': 2})['x'], 2);
      expect(JsonUtils.unwrapMap('garbage'), isEmpty);
    });
  });

  group('CourseModel — parsing', () {
    test('parses a fully populated course', () {
      final model = CourseModel.fromJson({
        'id': 'c1',
        'title': 'Flutter Fundamentals',
        'description': 'Learn Flutter',
        'price': 1500,
        'instructorName': 'Jane Doe',
        'lessonCount': 12,
        'isEnrolled': true,
        'isWishlisted': true,
        'rating': 4.5,
        'thumbnailPath': '/uploads/Images/x.png',
      });

      expect(model.id, 'c1');
      expect(model.title, 'Flutter Fundamentals');
      expect(model.price, 1500);
      expect(model.totalLessons, 12);
      expect(model.isEnrolled, isTrue);
      expect(model.isWishlisted, isTrue);
      expect(model.rating, 4.5);
    });

    test('a missing isWishlisted field defaults to false (the refresh bug)',
        () {
      // Course/GetAll does not send this field, so the model must not throw and
      // must default to false; the repository is what hydrates it afterwards.
      final model = CourseModel.fromJson({
        'id': 'c1',
        'title': 'Course',
        'price': 0,
      });
      expect(model.isWishlisted, isFalse);
    });

    test('tolerates price sent as a string', () {
      final model = CourseModel.fromJson({
        'id': 'c1',
        'title': 'Course',
        'price': '2500.50',
      });
      expect(model.price, 2500.5);
    });

    test('isEnrollable defaults to true so a missing flag never locks a course',
        () {
      final model = CourseModel.fromJson({'id': 'c1', 'title': 'C', 'price': 0});
      expect(model.isEnrollable, isTrue);
    });

    test('parses the nested lessons array', () {
      final model = CourseModel.fromJson({
        'id': 'c1',
        'title': 'C',
        'price': 0,
        'lessons': [
          {'id': 'l1', 'title': 'Intro'},
          {'id': 'l2', 'title': 'Setup'},
        ],
      });
      expect(model.lessons, hasLength(2));
      expect(model.lessons.first.title, 'Intro');
    });

    test('a malformed lessons value does not throw', () {
      final model = CourseModel.fromJson({
        'id': 'c1',
        'title': 'C',
        'price': 0,
        'lessons': 'not-a-list',
      });
      expect(model.lessons, isEmpty);
    });
  });

  group('AppConstants — asset URL resolution', () {
    test('blank and placeholder paths resolve to empty string', () {
      expect(AppConstants.resolveImageUrl(null), '');
      expect(AppConstants.resolveImageUrl(''), '');
      expect(AppConstants.resolveImageUrl('null'), '');
      expect(AppConstants.resolveImageUrl('undefined'), '');
    });

    test('a relative filename is prefixed with the asset host', () {
      expect(
        AppConstants.resolveImageUrl('course.jpg'),
        'https://api.nirvoor.com/uploads/Images/course.jpg',
      );
    });

    test('absolute URLs pass through unchanged', () {
      const url = 'https://cdn.example.com/a/b.png';
      expect(AppConstants.resolveImageUrl(url), url);
    });

    test('the SPA host is rewritten onto the asset host for uploads', () {
      // learning.nirvoor.com answers /uploads/* with the SPA's index.html.
      expect(
        AppConstants.resolveImageUrl(
          'https://learning.nirvoor.com/uploads/Images/t.png',
        ),
        'https://api.nirvoor.com/uploads/Images/t.png',
      );
    });

    test('isSvgUrl detects the extension with or without a query string', () {
      expect(AppConstants.isSvgUrl('https://x/y/icon.svg'), isTrue);
      expect(AppConstants.isSvgUrl('https://x/y/icon.svg?v=2'), isTrue);
      expect(AppConstants.isSvgUrl('https://x/y/pic.png'), isFalse);
    });
  });
}
