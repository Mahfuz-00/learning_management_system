import 'package:equatable/equatable.dart';

/// What kind of file a practice / suggestion entry holds.
///
/// Manual §4.3: *"Open them in a built-in viewer (PDF, image or video) — they do
/// not open in a blank new tab."*
enum PracticeFileType {
  pdf,
  image,
  video,
  document;

  /// Infers the type from a file URL extension.
  static PracticeFileType fromUrl(String? url) {
    final lower = (url ?? '').toLowerCase();
    if (lower.endsWith('.pdf')) return PracticeFileType.pdf;
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif')) {
      return PracticeFileType.image;
    }
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.m3u8')) {
      return PracticeFileType.video;
    }
    return PracticeFileType.document;
  }

  /// True when the in-app video player should be used.
  bool get isVideo => this == PracticeFileType.video;
}

/// A practice file or exam suggestion uploaded by admin.
///
/// These back two of the five course-hub cards: **Practice** ("Board questions,
/// model tests and other practice files") and **Suggestion** ("Exam suggestions
/// uploaded by admin").
class PracticeEntity extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String? description;

  /// Direct file URL used by the built-in viewer.
  final String? fileUrl;

  /// Whether this is a practice file or an exam suggestion.
  final bool isSuggestion;

  /// Category such as "Board Question" / "Model Test".
  final String? category;

  final DateTime? uploadedAt;

  const PracticeEntity({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.fileUrl,
    this.isSuggestion = false,
    this.category,
    this.uploadedAt,
  });

  /// The detected viewer type for [fileUrl].
  PracticeFileType get fileType => PracticeFileType.fromUrl(fileUrl);

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        fileUrl,
        isSuggestion,
        category,
        uploadedAt,
      ];
}