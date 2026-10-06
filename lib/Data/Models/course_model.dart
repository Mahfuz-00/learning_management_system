import '../../Domain/Entities/course_entity.dart';
import 'lesson_model.dart';

/// Data-layer representation of a course.
///
/// Extends [CourseEntity] so the presentation layer never sees JSON. All the
/// awkward backend field names are normalised **here and nowhere else**.
class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    super.description,
    super.thumbnail,
    required super.price,
    super.instructorName,
    super.totalLessons,
    super.isEnrolled,
    super.isWishlisted,
    super.lessons,
    super.durationMonths,
    super.isUpcoming,
    super.enrollmentOpensAt,
    super.startDate,
    super.endDate,
    super.isEnrollable,
    super.category,
    super.level,
    super.isPublished,
    super.marketingEnrollmentCount,
    super.realEnrollmentCount,
    super.marketingVideoText,
    super.marketingPracticeText,
    super.rating,
    super.isCompleted,
  });

  /// Parses a course from the API.
  ///
  /// Every read is defensive because the live Swagger spec declares **no
  /// response schema** for the course endpoints, so field presence cannot be
  /// guaranteed. Unknown shapes degrade to sensible defaults instead of
  /// throwing and blanking the screen.
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: (json['id'] ?? json['courseId'] ?? '').toString(),
      title: (json['title'] ?? json['courseTitle'] ?? '').toString(),
      description: json['description'] as String?,
      category: json['category'] as String?,
      level: json['level'] as String?,
      price: _toDouble(json['price']),
      // Rule 6: the wire field is literally named `durationMinutes` but the
      // value is MONTHS. It is mapped straight into `durationMonths`.
      durationMonths: _toInt(json['durationMonths'] ?? json['durationMinutes']),
      thumbnail: (json['thumbnailPath'] ?? json['thumbnail']) as String?,
      isPublished: json['isPublished'] as bool? ?? true,
      instructorName: (json['instructorName'] ?? json['teacherName']) as String?,
      totalLessons: _toInt(json['lessonCount'] ?? json['totalLessons']),
      isEnrolled: json['isEnrolled'] as bool? ?? false,
      isWishlisted: json['isWishlisted'] as bool? ?? false,

      // Rule 3 — upcoming courses are visible but not buyable.
      isUpcoming: json['isUpcoming'] as bool? ?? false,
      enrollmentOpensAt: _toDate(json['enrollmentOpensAt']),

      // Rule 2 — start date is the last day to enrol.
      startDate: _toDate(json['startDate']),
      endDate: _toDate(json['endDate']),

      // Defaults to true so a course is only treated as closed when the server
      // explicitly says so. This avoids locking students out on a missing field.
      isEnrollable: json['isEnrollable'] as bool? ?? true,

      // Rule 5 — real vs. marketing counts.
      marketingEnrollmentCount: _toNullableInt(
        json['marketingEnrollmentCount'] ?? json['displayEnrollmentCount'],
      ),
      realEnrollmentCount: _toNullableInt(
        json['realEnrollmentCount'] ?? json['enrollmentCount'],
      ),
      marketingVideoText: json['marketingVideoText'] as String?,
      marketingPracticeText: json['marketingPracticeText'] as String?,

      rating: json['rating'] != null ? _toDouble(json['rating']) : null,
      isCompleted: json['isCompleted'] as bool? ?? false,

      lessons: (json['lessons'] as List? ?? [])
          .whereType<Map>()
          .map((e) => LessonModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// Serialises back to JSON (used for Hive caching).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      'price': price,
      // Written as `durationMonths` so the cache round-trips unambiguously.
      'durationMonths': durationMonths,
      'thumbnailPath': thumbnail,
      'isPublished': isPublished,
      'instructorName': instructorName,
      'lessonCount': totalLessons,
      'isEnrolled': isEnrolled,
      'isWishlisted': isWishlisted,
      'isUpcoming': isUpcoming,
      'enrollmentOpensAt': enrollmentOpensAt?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isEnrollable': isEnrollable,
      'marketingEnrollmentCount': marketingEnrollmentCount,
      'realEnrollmentCount': realEnrollmentCount,
      'marketingVideoText': marketingVideoText,
      'marketingPracticeText': marketingPracticeText,
      'rating': rating,
      'isCompleted': isCompleted,
    };
  }

  // ── Parsing helpers ────────────────────────────────────────────────────

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// Parses an ISO-8601 date.
  ///
  /// **Timezone note (User Manual):** *"Every date and time in the system is
  /// Bangladesh time. There is no time-zone conversion anywhere, so what a
  /// teacher types is exactly what a student sees."*
  ///
  /// Therefore the parsed instant is used as a **wall-clock** value and is never
  /// converted to the device timezone.
  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final raw = value.toString();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
