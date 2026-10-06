import 'package:equatable/equatable.dart';
import 'lesson_entity.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? thumbnail;
  final double price;
  final String? instructorName;

  /// Number of lessons. NOTE: on catalogue cards the backend may return a
  /// **marketing** count (Rule 5), not the real one.
  final int totalLessons;

  final bool isEnrolled;
  final bool isWishlisted;
  final List<LessonEntity> lessons;

  // ── Rule 6 ────────────────────────────────────────────────────────────
  /// Course length in **MONTHS**, not minutes.
  ///
  /// **Rule 6 (User Manual):** "The field is stored with a name that says
  /// minutes, but every screen treats it as months, and the course end date is
  /// calculated from it. If you type 6, that means six months."
  ///
  /// The backend JSON key is still literally `durationMinutes`; it is renamed
  /// here so no future developer re-introduces the bug by dividing by 60.
  final int durationMonths;

  // ── Rule 3 ────────────────────────────────────────────────────────────
  /// True when the course is *Upcoming*: visible but **not buyable**.
  /// The UI must hide the price, hide the word "Free", disable Buy, and keep
  /// it out of "Most popular".
  final bool isUpcoming;

  /// Date on which an Upcoming course automatically starts selling.
  /// "You can give it a date to open by itself — on that day it starts selling
  /// with nobody having to touch anything." (Rule 3)
  final DateTime? enrollmentOpensAt;

  // ── Rule 2 ────────────────────────────────────────────────────────────
  /// The start date **is also the last day to enrol** (Rule 2).
  final DateTime? startDate;
  final DateTime? endDate;

  /// Server-computed flag telling the client whether the Enrol button should
  /// be enabled. This exists because Rule 2 hides a started course from the
  /// catalogue but a *deep link* must still render a clear "enrollment closed"
  /// state rather than a bare 404.
  final bool isEnrollable;

  final String? category;
  final String? level;
  final bool isPublished;

  // ── Rule 5 ────────────────────────────────────────────────────────────
  /// **Inflated marketing count shown on cards.** Never use this to verify
  /// that an enrollment worked — use `My Courses` or the admin panel instead.
  final int? marketingEnrollmentCount;

  /// Real enrollment count. Only populated by the course **details** endpoint
  /// ("The course details page shows true counts" — Rule 5).
  final int? realEnrollmentCount;

  /// Marketing text such as "24+" shown on the video badge.
  final String? marketingVideoText;

  /// Marketing text such as "50+" shown on the practice badge.
  final String? marketingPracticeText;

  /// Average rating (0–5) shown on catalogue cards.
  final double? rating;

  /// Whether the current user has completed this course.
  final bool isCompleted;

  const CourseEntity({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    required this.price,
    this.instructorName,
    this.totalLessons = 0,
    this.isEnrolled = false,
    this.isWishlisted = false,
    this.lessons = const [],
    this.durationMonths = 0,
    this.isUpcoming = false,
    this.enrollmentOpensAt,
    this.startDate,
    this.endDate,
    this.isEnrollable = true,
    this.category,
    this.level,
    this.isPublished = true,
    this.marketingEnrollmentCount,
    this.realEnrollmentCount,
    this.marketingVideoText,
    this.marketingPracticeText,
    this.rating,
    this.isCompleted = false,
  });

  /// The count a **card** should display (Rule 5: marketing + real).
  int get displayEnrollmentCount =>
      marketingEnrollmentCount ?? realEnrollmentCount ?? 0;

  /// True when the course is free **and** actually sellable.
  /// An Upcoming course is never "Free" on screen, even at price 0 (Rule 3).
  bool get isFree => !isUpcoming && price <= 0;

  /// True when the Buy button may be shown at all.
  bool get isPurchasable => !isUpcoming && isEnrollable && !isEnrolled;

  /// True when the course should render the "Coming soon" state (Rule 3).
  bool get isComingSoon => isUpcoming;

  /// True when enrollment has closed because the start date passed (Rule 2).
  bool get isEnrollmentClosed => !isEnrollable && !isEnrolled;

  /// Returns a copy with the wishlist flag replaced.
  ///
  /// Used by `CourseBloc` to update the heart icon in place instead of
  /// refetching the whole catalogue.
  CourseEntity copyWithWishlist(bool wishlisted) {
    return CourseEntity(
      id: id,
      title: title,
      description: description,
      thumbnail: thumbnail,
      price: price,
      instructorName: instructorName,
      totalLessons: totalLessons,
      isEnrolled: isEnrolled,
      isWishlisted: wishlisted,
      lessons: lessons,
      durationMonths: durationMonths,
      isUpcoming: isUpcoming,
      enrollmentOpensAt: enrollmentOpensAt,
      startDate: startDate,
      endDate: endDate,
      isEnrollable: isEnrollable,
      category: category,
      level: level,
      isPublished: isPublished,
      marketingEnrollmentCount: marketingEnrollmentCount,
      realEnrollmentCount: realEnrollmentCount,
      marketingVideoText: marketingVideoText,
      marketingPracticeText: marketingPracticeText,
      rating: rating,
      isCompleted: isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        thumbnail,
        price,
        instructorName,
        totalLessons,
        isEnrolled,
        isWishlisted,
        lessons,
        durationMonths,
        isUpcoming,
        enrollmentOpensAt,
        startDate,
        endDate,
        isEnrollable,
        category,
        level,
        isPublished,
        marketingEnrollmentCount,
        realEnrollmentCount,
        marketingVideoText,
        marketingPracticeText,
        rating,
        isCompleted,
      ];
}
