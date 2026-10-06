import 'package:equatable/equatable.dart';

/// A student's combined progress through one course.
///
/// **The weighting is fixed by the User Manual (§4.3):**
/// *"One combined number: video 40%, quiz 15%, exam 15%, live exam 20%,
/// attendance 10%."*
///
/// The five components are kept separate (not just the total) so the dashboard
/// can render a breakdown bar explaining *where* the number comes from.
class CourseProgressEntity extends Equatable {
  final String courseId;
  final String courseTitle;

  /// 0–100 contribution from watched video lessons (max 40).
  final double videoProgress;

  /// 0–100 contribution from quizzes (max 15).
  final double quizProgress;

  /// 0–100 contribution from course exams (max 15).
  final double examProgress;

  /// 0–100 contribution from live-class exams (max 20).
  final double liveExamProgress;

  /// 0–100 contribution from live-class attendance (max 10).
  final double attendanceProgress;

  /// Combined 0–100 total. Falls back to a locally-computed sum if the server
  /// does not send one.
  final double overallProgress;

  /// Number of lessons marked complete.
  final int completedLessons;

  /// Total lessons in the course.
  final int totalLessons;

  /// True when the course has been finished (certificate becomes available).
  final bool isCompleted;

  const CourseProgressEntity({
    required this.courseId,
    required this.courseTitle,
    this.videoProgress = 0,
    this.quizProgress = 0,
    this.examProgress = 0,
    this.liveExamProgress = 0,
    this.attendanceProgress = 0,
    this.overallProgress = 0,
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.isCompleted = false,
  });

  /// Recomputes the total from the five weighted parts, each already scaled to
  /// its maximum. Used when the server omits `overallProgress`.
  double get computedOverall {
    final sum = videoProgress + quizProgress + examProgress +
        liveExamProgress + attendanceProgress;
    return sum.clamp(0, 100).toDouble();
  }

  /// The value the UI should display.
  double get effectiveOverall =>
      overallProgress > 0 ? overallProgress : computedOverall;

  @override
  List<Object?> get props => [
        courseId,
        courseTitle,
        videoProgress,
        quizProgress,
        examProgress,
        liveExamProgress,
        attendanceProgress,
        overallProgress,
        completedLessons,
        totalLessons,
        isCompleted,
      ];
}

/// One entry in the student's watch history (Manual §4.3).
///
/// *"Everything watched, newest first, like YouTube history. Removing an item
/// only hides it — it does not delete the progress."*
///
/// This distinction is why [isHidden] exists separately from the progress
/// values: a hidden item can be **restored** without losing watched time.
class WatchHistoryItemEntity extends Equatable {
  final String id;

  /// The lesson or recording this entry refers to.
  final String contentId;

  /// Either 'lesson', 'recording' or 'free-recording'.
  final String contentType;

  final String title;
  final String courseTitle;
  final String? courseId;
  final String? thumbnail;

  /// Seconds watched so far.
  final double watchedSeconds;
  final double totalSeconds;

  /// When the student last watched it.
  final DateTime? lastWatchedAt;

  /// True when the student has removed it from the visible list.
  /// The progress is still intact and can be restored.
  final bool isHidden;

  const WatchHistoryItemEntity({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.title,
    this.courseTitle = '',
    this.courseId,
    this.thumbnail,
    this.watchedSeconds = 0,
    this.totalSeconds = 0,
    this.lastWatchedAt,
    this.isHidden = false,
  });

  /// 0–100 completion of this single item.
  double get percentComplete {
    if (totalSeconds <= 0) return 0;
    return ((watchedSeconds / totalSeconds) * 100).clamp(0, 100).toDouble();
  }

  /// True when the item is a lesson (as opposed to a live-class recording).
  bool get isLesson => contentType == 'lesson';

  /// Returns a copy with the hidden flag flipped.
  ///
  /// Used by the history BLoC so the list updates instantly without a reload.
  /// The underlying progress is untouched — hiding is reversible by design
  /// (Manual §4.3).
  WatchHistoryItemEntity copyWithHidden(bool hidden) {
    return WatchHistoryItemEntity(
      id: id,
      contentId: contentId,
      contentType: contentType,
      title: title,
      courseTitle: courseTitle,
      courseId: courseId,
      thumbnail: thumbnail,
      watchedSeconds: watchedSeconds,
      totalSeconds: totalSeconds,
      lastWatchedAt: lastWatchedAt,
      isHidden: hidden,
    );
  }

  @override
  List<Object?> get props => [
        id,
        contentId,
        contentType,
        title,
        courseTitle,
        courseId,
        thumbnail,
        watchedSeconds,
        totalSeconds,
        lastWatchedAt,
        isHidden,
      ];
}