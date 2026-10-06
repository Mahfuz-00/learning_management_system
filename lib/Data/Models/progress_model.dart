import '../../Domain/Entities/progress_entity.dart';
import 'json_utils.dart';

/// JSON mapping for a student's weighted course progress.
///
/// **The weighting is fixed by the User Manual (§4.3):**
/// video 40% + quiz 15% + exam 15% + live exam 20% + attendance 10%.
///
/// Because the backend's `/api/Progress/my` response is untyped in the spec,
/// this model accepts several plausible field spellings for each component and
/// falls back to a locally-computed sum when the server omits the total.
class CourseProgressModel extends CourseProgressEntity {
  const CourseProgressModel({
    required super.courseId,
    required super.courseTitle,
    super.videoProgress,
    super.quizProgress,
    super.examProgress,
    super.liveExamProgress,
    super.attendanceProgress,
    super.overallProgress,
    super.completedLessons,
    super.totalLessons,
    super.isCompleted,
  });

  factory CourseProgressModel.fromJson(Map<String, dynamic> json) {
    return CourseProgressModel(
      courseId: JsonUtils.toStringValue(json['courseId']),
      courseTitle: JsonUtils.toStringValue(
        json['courseTitle'] ?? json['title'],
        fallback: 'Course',
      ),
      videoProgress: JsonUtils.toDouble(
        json['videoProgress'] ?? json['video'] ?? json['videoPercent'],
      ),
      quizProgress: JsonUtils.toDouble(
        json['quizProgress'] ?? json['quiz'] ?? json['quizPercent'],
      ),
      examProgress: JsonUtils.toDouble(
        json['examProgress'] ?? json['exam'] ?? json['examPercent'],
      ),
      liveExamProgress: JsonUtils.toDouble(
        json['liveExamProgress'] ?? json['liveExam'] ?? json['liveExamPercent'],
      ),
      attendanceProgress: JsonUtils.toDouble(
        json['attendanceProgress'] ?? json['attendance'] ?? json['attendancePercent'],
      ),
      overallProgress: JsonUtils.toDouble(
        json['overallProgress'] ?? json['progress'] ?? json['overall'],
      ),
      completedLessons: JsonUtils.toInt(
        json['completedLessons'] ?? json['watchedLessons'],
      ),
      totalLessons: JsonUtils.toInt(json['totalLessons'] ?? json['lessonCount']),
      isCompleted: JsonUtils.toBool(json['isCompleted']),
    );
  }

  Map<String, dynamic> toJson() => {
        'courseId': courseId,
        'courseTitle': courseTitle,
        'videoProgress': videoProgress,
        'quizProgress': quizProgress,
        'examProgress': examProgress,
        'liveExamProgress': liveExamProgress,
        'attendanceProgress': attendanceProgress,
        'overallProgress': overallProgress,
        'completedLessons': completedLessons,
        'totalLessons': totalLessons,
        'isCompleted': isCompleted,
      };
}

/// JSON mapping for one watch-history entry (Manual §4.3).
class WatchHistoryItemModel extends WatchHistoryItemEntity {
  const WatchHistoryItemModel({
    required super.id,
    required super.contentId,
    required super.contentType,
    required super.title,
    super.courseTitle,
    super.courseId,
    super.thumbnail,
    super.watchedSeconds,
    super.totalSeconds,
    super.lastWatchedAt,
    super.isHidden,
  });

  factory WatchHistoryItemModel.fromJson(Map<String, dynamic> json) {
    // The backend may return either a lesson id or a recording id depending on
    // which history feed the entry came from.
    final contentId = JsonUtils.toStringValue(
      json['lessonId'] ?? json['liveClassId'] ?? json['freeLiveClassId'] ?? json['id'],
    );
    final hasRecording = json['liveClassId'] != null;
    final hasFreeRecording = json['freeLiveClassId'] != null;

    return WatchHistoryItemModel(
      id: JsonUtils.toStringValue(json['id'] ?? contentId),
      contentId: contentId,
      contentType: JsonUtils.toStringValue(
        json['contentType'],
        fallback: hasFreeRecording
            ? 'free-recording'
            : (hasRecording ? 'recording' : 'lesson'),
      ),
      title: JsonUtils.toStringValue(
        json['title'] ?? json['lessonTitle'],
        fallback: 'Untitled',
      ),
      courseTitle: JsonUtils.toStringValue(json['courseTitle'] ?? json['courseName']),
      courseId: JsonUtils.toStringOrNull(json['courseId']),
      thumbnail: JsonUtils.toStringOrNull(json['thumbnailPath'] ?? json['thumbnail']),
      watchedSeconds: JsonUtils.toDouble(json['watchedSeconds']),
      totalSeconds: JsonUtils.toDouble(json['totalSeconds']),
      lastWatchedAt: JsonUtils.toDate(json['lastWatchedAt'] ?? json['watchedAt']),
      isHidden: JsonUtils.toBool(json['isHidden']),
    );
  }
}