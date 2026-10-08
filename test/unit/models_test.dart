// Model JSON tests — serialization/deserialization for every model in
// lib/Data/Models.
//
// The backend's Swagger spec declares almost no response schemas, so these tests
// lock in the two contracts that matter:
//   1. a well-formed payload maps to the right entity fields;
//   2. a malformed/partial payload (wrong type, missing field) does not throw —
//      it degrades to a sensible default.

import 'package:flutter_test/flutter_test.dart';

import 'package:lms_touch_and_solve/Data/Models/certificate_model.dart';
import 'package:lms_touch_and_solve/Data/Models/comment_model.dart';
import 'package:lms_touch_and_solve/Data/Models/course_model.dart';
import 'package:lms_touch_and_solve/Data/Models/lesson_model.dart';
import 'package:lms_touch_and_solve/Data/Models/live_class_model.dart';
import 'package:lms_touch_and_solve/Data/Models/payment_model.dart';
import 'package:lms_touch_and_solve/Data/Models/quiz_model.dart';
import 'package:lms_touch_and_solve/Data/Models/refund_model.dart';
import 'package:lms_touch_and_solve/Data/Models/store_item_model.dart';
import 'package:lms_touch_and_solve/Data/Models/student_profile_model.dart';
import 'package:lms_touch_and_solve/Data/Models/user_model.dart';
import 'package:lms_touch_and_solve/Data/Models/user_preference_model.dart';

void main() {
  // ── Course ────────────────────────────────────────────────────────────────
  group('CourseModel', () {
    test('maps a fully populated payload', () {
      final m = CourseModel.fromJson({
        'id': 'c1',
        'title': 'Flutter Fundamentals',
        'description': 'desc',
        'price': 1500,
        'instructorName': 'Jane Doe',
        'lessonCount': 12,
        'isEnrolled': true,
        'isWishlisted': true,
        'rating': 4.5,
      });

      expect(m.id, 'c1');
      expect(m.title, 'Flutter Fundamentals');
      expect(m.price, 1500);
      expect(m.instructorName, 'Jane Doe');
      expect(m.totalLessons, 12);
      expect(m.isEnrolled, isTrue);
      expect(m.isWishlisted, isTrue);
      expect(m.rating, 4.5);
    });

    test('missing isWishlisted defaults to false (raw API shape)', () {
      final m = CourseModel.fromJson({'id': 'c', 'title': 'T', 'price': 0});
      expect(m.isWishlisted, isFalse);
    });

    test('accepts a string price', () {
      final m = CourseModel.fromJson({'id': 'c', 'title': 'T', 'price': '2500.50'});
      expect(m.price, 2500.5);
    });

    test('isEnrollable defaults to true when absent', () {
      final m = CourseModel.fromJson({'id': 'c', 'title': 'T', 'price': 0});
      expect(m.isEnrollable, isTrue);
    });

    test('parses nested lessons', () {
      final m = CourseModel.fromJson({
        'id': 'c',
        'title': 'T',
        'price': 0,
        'lessons': [
          {'id': 'l1', 'title': 'Intro'},
          {'id': 'l2', 'title': 'Setup'},
        ],
      });
      expect(m.lessons, hasLength(2));
      expect(m.lessons.first.title, 'Intro');
    });

    test('tolerates a non-list lessons value', () {
      final m = CourseModel.fromJson({
        'id': 'c',
        'title': 'T',
        'price': 0,
        'lessons': 'garbage',
      });
      expect(m.lessons, isEmpty);
    });

    test('round-trips through toJson', () {
      final original = CourseModel.fromJson({
        'id': 'c1',
        'title': 'Round Trip',
        'price': 999,
        'isWishlisted': true,
      });
      final restored = CourseModel.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.price, original.price);
      expect(restored.isWishlisted, original.isWishlisted);
    });
  });

  // ── User ──────────────────────────────────────────────────────────────────
  group('UserModel', () {
    test('reads id from userId or id', () {
      expect(UserModel.fromJson({'userId': 'u1'}).id, 'u1');
      expect(UserModel.fromJson({'id': 'u2'}).id, 'u2');
    });

    test('falls back to name when fullName is absent', () {
      final m = UserModel.fromJson({'userId': 'u1', 'name': 'Ali'});
      expect(m.fullName, 'Ali');
    });

    test('defaults role to 0 and email to empty', () {
      final m = UserModel.fromJson({'userId': 'u1'});
      expect(m.role, 0);
      expect(m.email, '');
    });

    test('carries the token and status through', () {
      final m = UserModel.fromJson({
        'userId': 'u1',
        'token': 'jwt.abc',
        'status': 'Approved',
        'profileImagePath': '/img/a.png',
      });
      expect(m.token, 'jwt.abc');
      expect(m.status, 'Approved');
      expect(m.profilePicture, '/img/a.png');
    });

    test('round-trips through toJson', () {
      final m = UserModel.fromJson({'userId': 'u1', 'fullName': 'Test', 'role': 1});
      final r = UserModel.fromJson(m.toJson());
      expect(r.id, 'u1');
      expect(r.fullName, 'Test');
      expect(r.role, 1);
    });
  });

  // ── Lesson ────────────────────────────────────────────────────────────────
  group('LessonModel', () {
    test('maps description/videoPath variants', () {
      final m = LessonModel.fromJson({
        'guid': 'l1',
        'courseId': 'c1',
        'title': 'Intro',
        'description': 'Body',
        'videoPath': '/v/l1.mp4',
        'isCompleted': true,
      });
      expect(m.id, 'l1');
      expect(m.content, 'Body');
      expect(m.videoUrl, '/v/l1.mp4');
      expect(m.isCompleted, isTrue);
    });

    test('sets youtubeUrl only when videoType is YouTube', () {
      final yt = LessonModel.fromJson({
        'id': 'l',
        'videoType': 'YouTube',
        'videoUrl': 'https://youtu.be/x',
      });
      expect(yt.youtubeUrl, 'https://youtu.be/x');

      final mp4 = LessonModel.fromJson({'id': 'l', 'videoType': 'Mp4', 'videoUrl': 'x'});
      expect(mp4.youtubeUrl, isNull);
    });

    test('missing fields degrade to safe defaults', () {
      final m = LessonModel.fromJson({});
      expect(m.id, '');
      expect(m.title, '');
      expect(m.isCompleted, isFalse);
    });

    test('round-trips through toJson', () {
      final m = LessonModel.fromJson({'id': 'l1', 'courseId': 'c1', 'title': 'T'});
      expect(LessonModel.fromJson(m.toJson()).title, 'T');
    });
  });

  // ── Quiz ──────────────────────────────────────────────────────────────────
  group('QuizModel', () {
    test('parses questions from the data envelope', () {
      final m = QuizModel.fromJson({
        'data': [
          {'id': 'q1', 'question': '2+2?', 'options': ['3', '4'], 'correctAnswer': '4'},
        ],
      });
      expect(m.questions, hasLength(1));
      expect(m.questions.first.text, '2+2?');
      expect(m.questions.first.options, ['3', '4']);
    });

    test('a missing data list yields no questions', () {
      expect(QuizModel.fromJson({}).questions, isEmpty);
    });

    test('QuestionModel tolerates missing options', () {
      final q = QuestionModel.fromJson({'id': 'q1', 'question': 'Q'});
      expect(q.options, isEmpty);
    });
  });

  // ── Certificate ───────────────────────────────────────────────────────────
  group('CertificateModel', () {
    test('parses an issued certificate', () {
      final m = CertificateModel.fromJson({
        'id': 'cert1',
        'courseId': 'c1',
        'courseTitle': 'Flutter',
        'studentName': 'Ali',
        'issuedAt': '2026-01-15T10:00:00',
        'certificateUrl': '/c/cert1.pdf',
      });
      expect(m.id, 'cert1');
      expect(m.studentName, 'Ali');
      expect(m.issuedAt, DateTime(2026, 1, 15, 10));
      expect(m.certificateUrl, '/c/cert1.pdf');
    });

    test('a missing issuedAt defaults to now instead of throwing', () {
      expect(CertificateModel.fromJson({'id': 'x'}).issuedAt, isA<DateTime>());
    });

    test('round-trips through toJson', () {
      final m = CertificateModel.fromJson({
        'id': 'c1',
        'courseId': 'c',
        'courseTitle': 'T',
        'studentName': 'S',
        'issuedAt': '2026-01-01T00:00:00',
      });
      expect(CertificateModel.fromJson(m.toJson()).id, 'c1');
    });
  });

  // ── Store item ────────────────────────────────────────────────────────────
  group('StoreItemModel', () {
    test('parses a store item', () {
      final m = StoreItemModel.fromJson({
        'id': 's1',
        'title': 'Book',
        'description': 'A book',
        'price': 500,
        'author': 'Ali',
      });
      expect(m.id, 's1');
      expect(m.price, 500);
      expect(m.author, 'Ali');
    });

    test('accepts a string price (backend sends numbers as strings)', () {
      final m = StoreItemModel.fromJson({'id': 's1', 'title': 'B', 'price': '750.5'});
      expect(m.price, 750.5);
    });

    test('uses the image field when thumbnail is absent', () {
      final m = StoreItemModel.fromJson({'id': 's', 'title': 'B', 'price': 0, 'image': '/i.png'});
      expect(m.thumbnail, '/i.png');
    });
  });

  // ── Live class ────────────────────────────────────────────────────────────
  group('LiveClassModel', () {
    test('parses a scheduled class', () {
      final m = LiveClassModel.fromJson({
        'id': 'lc1',
        'courseId': 'c1',
        'title': 'Doubt Session',
        'scheduledAt': '2026-02-01T09:00:00',
        'roomUrl': 'https://meet/x',
        'status': 'Upcoming',
      });
      expect(m.title, 'Doubt Session');
      expect(m.scheduledAt, DateTime(2026, 2, 1, 9));
      expect(m.status, 'Upcoming');
    });

    test('defaults status to Upcoming and tolerates a missing date', () {
      final m = LiveClassModel.fromJson({'id': 'x', 'title': 'T'});
      expect(m.status, 'Upcoming');
      expect(m.scheduledAt, isA<DateTime>());
    });
  });

  // ── Comment ───────────────────────────────────────────────────────────────
  group('CommentModel', () {
    test('parses a comment', () {
      final m = CommentModel.fromJson({
        'id': 'k1',
        'courseId': 'c1',
        'userId': 'u1',
        'userName': 'Ali',
        'content': 'Great course',
        'createdAt': '2026-03-01T12:00:00',
      });
      expect(m.userName, 'Ali');
      expect(m.content, 'Great course');
    });

    test('defaults the user name to Anonymous', () {
      expect(CommentModel.fromJson({'id': 'k'}).userName, 'Anonymous');
    });

    test('round-trips through toJson', () {
      final m = CommentModel.fromJson({
        'id': 'k1',
        'courseId': 'c1',
        'userId': 'u1',
        'userName': 'A',
        'content': 'c',
        'createdAt': '2026-01-01T00:00:00',
      });
      expect(CommentModel.fromJson(m.toJson()).content, 'c');
    });
  });

  // ── User preferences ──────────────────────────────────────────────────────
  group('UserPreferenceModel', () {
    test('parses categories and goals', () {
      final m = UserPreferenceModel.fromJson({
        'categories': ['Math', 'Science'],
        'learningGoal': 'Exam prep',
        'dailyTime': '1 hour',
      });
      expect(m.categories, ['Math', 'Science']);
      expect(m.learningGoal, 'Exam prep');
    });

    test('missing categories yields an empty list, not a crash', () {
      expect(UserPreferenceModel.fromJson({}).categories, isEmpty);
    });

    test('round-trips through toJson', () {
      const m = UserPreferenceModel(
        categories: ['A'],
        learningGoal: 'g',
        dailyTime: 'd',
      );
      final r = UserPreferenceModel.fromJson(m.toJson());
      expect(r.categories, ['A']);
      expect(r.learningGoal, 'g');
    });
  });

  // ── Student profile ───────────────────────────────────────────────────────
  group('StudentProfileModel', () {
    test('maps the onboarding fields', () {
      final m = StudentProfileModel.fromJson({
        'fullName': 'Ali',
        'mobileNumber': '01712345678',
        'institution': 'Dhaka College',
        'guardianName': 'Abu',
        'agreedInfoCorrect': true,
      });
      expect(m.fullName, 'Ali');
      expect(m.institution, 'Dhaka College');
      expect(m.guardianName, 'Abu');
      expect(m.agreedInfoCorrect, isTrue);
    });

    test('explicit needsOnboarding flag wins', () {
      expect(StudentProfileModel.fromJson({'needsOnboarding': true}).needsOnboarding, isTrue);
      expect(StudentProfileModel.fromJson({'needsOnboarding': false}).needsOnboarding, isFalse);
    });

    test('isOnboardingComplete inverts into needsOnboarding', () {
      // Complete => no onboarding needed.
      expect(
        StudentProfileModel.fromJson({'isOnboardingComplete': true}).needsOnboarding,
        isFalse,
      );
      expect(
        StudentProfileModel.fromJson({'isOnboardingComplete': false}).needsOnboarding,
        isTrue,
      );
    });

    test('infers onboarding is needed when the profile is empty', () {
      expect(StudentProfileModel.fromJson({}).needsOnboarding, isTrue);
    });

    test('infers onboarding is NOT needed once a profile exists', () {
      final m = StudentProfileModel.fromJson({'institution': 'X'});
      expect(m.needsOnboarding, isFalse);
    });
  });

  // ── Payment ───────────────────────────────────────────────────────────────
  group('PaymentQuoteModel', () {
    test('normalises a flat discount list and keeps exactly one applied', () {
      final m = PaymentQuoteModel.fromJson({
        'originalPrice': 1000,
        'payableAmount': 700,
        'discounts': [
          {'source': 'coupon', 'label': 'EID2026', 'amountInTaka': 300, 'isApplied': true},
          {'source': 'corporate', 'label': 'Acme', 'amountInTaka': 150, 'isApplied': false},
        ],
      });
      expect(m.appliedDiscount?.label, 'EID2026');
      expect(m.losingOffers, hasLength(1));
      expect(m.allOffers.where((o) => o.isApplied).length, 1);
      expect(m.payableAmount, 700);
    });

    test('reads the appliedDiscount object form', () {
      final m = PaymentQuoteModel.fromJson({
        'originalPrice': 500,
        'appliedDiscount': {'label': 'SAVE', 'amountInTaka': 500},
        'payableAmount': 0,
      });
      expect(m.appliedDiscount?.isApplied, isTrue);
      expect(m.isFullyDiscounted, isTrue);
    });

    test('payable falls back to the original price when absent', () {
      final m = PaymentQuoteModel.fromJson({'originalPrice': 800});
      expect(m.payableAmount, 800);
    });

    test('isFullyDiscounted defaults from a zero payable amount', () {
      final m = PaymentQuoteModel.fromJson({'originalPrice': 100, 'payableAmount': 0});
      expect(m.isFullyDiscounted, isTrue);
    });
  });

  group('PaymentInitiationModel', () {
    test('parses gateway URLs and status', () {
      final m = PaymentInitiationModel.fromJson({
        'transactionId': 't1',
        'status': 'Pending',
        'redirectUrl': 'https://pay/x',
        'amount': 500,
      });
      expect(m.transactionId, 't1');
      expect(m.gatewayUrl, 'https://pay/x');
      expect(m.amount, 500);
    });

    test('tolerates an empty payload', () {
      final m = PaymentInitiationModel.fromJson({});
      expect(m.transactionId, '');
    });
  });

  group('CorporateCouponModel', () {
    test('parses a company discount', () {
      final m = CorporateCouponModel.fromJson({
        'id': 'cc1',
        'companyName': 'Acme',
        'percent': 10,
      });
      expect(m.companyName, 'Acme');
      expect(m.percent, 10);
    });

    test('defaults the company name', () {
      expect(CorporateCouponModel.fromJson({}).companyName, 'Company');
    });
  });

  // ── Refund ────────────────────────────────────────────────────────────────
  group('RefundEligibilityModel', () {
    test('parses eligibility and reason', () {
      final m = RefundEligibilityModel.fromJson({
        'isEligible': true,
        'reason': 'Within 7 days',
        'refundableAmount': 900,
      });
      expect(m.isEligible, isTrue);
      expect(m.reason, 'Within 7 days');
      expect(m.refundableAmount, 900);
    });

    test('accepts the alternate "eligible" key', () {
      expect(RefundEligibilityModel.fromJson({'eligible': 'true'}).isEligible, isTrue);
    });
  });

  group('RefundModel', () {
    test('parses a refund request', () {
      final m = RefundModel.fromJson({
        'refundId': 'r1',
        'courseId': 'c1',
        'courseName': 'Flutter',
        'reason': 'Changed plans',
        'status': 'Pending',
        'amount': 500,
      });
      expect(m.id, 'r1');
      expect(m.courseId, 'c1');
      expect(m.refundedAmount, 500);
    });

    test('defaults the course title', () {
      expect(RefundModel.fromJson({}).courseTitle, 'Course');
    });
  });
}
