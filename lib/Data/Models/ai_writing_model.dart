import '../../Domain/Entities/ai_writing_entity.dart';
import 'json_utils.dart';

/// JSON mapping for an AI writing task (Manual §4.4).
class AiWritingTaskModel extends AiWritingTaskEntity {
  const AiWritingTaskModel({
    required super.id,
    required super.courseId,
    required super.title,
    super.type,
    super.instructions,
    super.topics,
    super.isPublished,
    super.maxMarks,
    super.attemptCount,
    super.latestMark,
    super.latestFeedback,
    super.hasSubmitted,
  });

  factory AiWritingTaskModel.fromJson(Map<String, dynamic> json) {
    return AiWritingTaskModel(
      id: JsonUtils.toStringValue(json['id'] ?? json['taskId']),
      courseId: JsonUtils.toStringValue(json['courseId']),
      title: JsonUtils.toStringValue(json['title'], fallback: 'AI Writing Task'),
      type: JsonUtils.toStringOrNull(json['type']),
      instructions: JsonUtils.toStringOrNull(json['instructions']),
      topics: (json['topics'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      isPublished: JsonUtils.toBool(json['isPublished'], fallback: true),
      // Marks are always out of 100 per the User Manual.
      maxMarks: JsonUtils.toInt(json['maxMarks'], fallback: 100),
      attemptCount: JsonUtils.toInt(json['attemptCount']),
      latestMark: JsonUtils.toIntOrNull(json['latestMark'] ?? json['mark']),
      latestFeedback: JsonUtils.toStringOrNull(json['latestFeedback'] ?? json['feedback']),
      hasSubmitted: JsonUtils.toBool(json['hasSubmitted']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'title': title,
        'type': type,
        'instructions': instructions,
        'topics': topics,
        'isPublished': isPublished,
        'maxMarks': maxMarks,
        'attemptCount': attemptCount,
        'latestMark': latestMark,
        'latestFeedback': latestFeedback,
        'hasSubmitted': hasSubmitted,
      };
}

/// JSON mapping for a single handwriting submission.
class AiWritingSubmissionModel extends AiWritingSubmissionEntity {
  const AiWritingSubmissionModel({
    required super.id,
    required super.taskId,
    required super.studentId,
    required super.studentName,
    super.attemptNumber,
    super.isLatest,
    super.aiMark,
    super.finalMark,
    super.feedback,
    super.fileUrl,
    super.submittedAt,
    super.overriddenBy,
  });

  factory AiWritingSubmissionModel.fromJson(Map<String, dynamic> json) {
    return AiWritingSubmissionModel(
      id: JsonUtils.toStringValue(json['id'] ?? json['submissionId']),
      taskId: JsonUtils.toStringValue(json['taskId']),
      studentId: JsonUtils.toStringValue(json['studentId'] ?? json['userId']),
      studentName: JsonUtils.toStringValue(
        json['studentName'] ?? json['fullName'],
        fallback: 'Student',
      ),
      attemptNumber: JsonUtils.toInt(json['attemptNumber'], fallback: 1),
      isLatest: JsonUtils.toBool(json['isLatest'], fallback: true),
      aiMark: JsonUtils.toIntOrNull(json['aiMark']),
      finalMark: JsonUtils.toIntOrNull(json['finalMark'] ?? json['marks']),
      feedback: JsonUtils.toStringOrNull(json['feedback']),
      fileUrl: JsonUtils.toStringOrNull(json['fileUrl'] ?? json['answerFileUrl']),
      submittedAt: JsonUtils.toDate(json['submittedAt'] ?? json['createdAt']),
      overriddenBy: JsonUtils.toStringOrNull(json['overriddenBy'] ?? json['gradedBy']),
    );
  }
}