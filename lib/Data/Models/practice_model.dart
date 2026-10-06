import '../../Domain/Entities/practice_entity.dart';
import 'json_utils.dart';

/// JSON mapping for a practice file or exam suggestion.
///
/// Backs the **Practice** and **Suggestion** hub cards (Manual §4.3). The file
/// type is inferred from the URL so the built-in viewer can pick the right
/// renderer — the manual is explicit that these must **not** open in a blank
/// new tab.
class PracticeModel extends PracticeEntity {
  const PracticeModel({
    required super.id,
    required super.courseId,
    required super.title,
    super.description,
    super.fileUrl,
    super.isSuggestion,
    super.category,
    super.uploadedAt,
  });

  factory PracticeModel.fromJson(Map<String, dynamic> json) {
    // "Suggestion" files live in the same collection as practice files; the
    // server distinguishes them by type/category or an explicit flag.
    final typeRaw = JsonUtils.toStringValue(
      json['type'] ?? json['category'],
    ).toLowerCase();
    final isSuggestion = JsonUtils.toBool(
      json['isSuggestion'],
      fallback: typeRaw.contains('suggestion'),
    );

    return PracticeModel(
      id: JsonUtils.toStringValue(json['id'] ?? json['practiceId']),
      courseId: JsonUtils.toStringValue(json['courseId']),
      title: JsonUtils.toStringValue(
        json['title'] ?? json['name'],
        fallback: isSuggestion ? 'Suggestion' : 'Practice Material',
      ),
      description: JsonUtils.toStringOrNull(json['description']),
      fileUrl: JsonUtils.toStringOrNull(
        json['fileUrl'] ?? json['filePath'] ?? json['url'],
      ),
      isSuggestion: isSuggestion,
      category: JsonUtils.toStringOrNull(json['category'] ?? json['type']),
      uploadedAt: JsonUtils.toDate(json['uploadedAt'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'title': title,
        'description': description,
        'fileUrl': fileUrl,
        'isSuggestion': isSuggestion,
        'category': category,
        'uploadedAt': uploadedAt?.toIso8601String(),
      };
}