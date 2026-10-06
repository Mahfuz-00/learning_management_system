import 'package:equatable/equatable.dart';

/// Base class for progress and watch-history events.
abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the student's weighted progress across all enrolled courses.
class LoadMyProgress extends ProgressEvent {
  const LoadMyProgress();
}

/// Loads the watch history (newest first, like YouTube history).
class LoadWatchHistory extends ProgressEvent {
  final String userId;
  const LoadWatchHistory(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Hides one history item without deleting the underlying progress.
///
/// Manual §4.3: *"Removing an item only hides it — it does not delete the
/// progress."*
class HideHistoryItem extends ProgressEvent {
  final String userId;
  final String contentId;
  final bool isRecording;
  const HideHistoryItem({
    required this.userId,
    required this.contentId,
    this.isRecording = false,
  });

  @override
  List<Object?> get props => [userId, contentId, isRecording];
}

/// Restores a previously hidden history item.
class RestoreHistoryItem extends ProgressEvent {
  final String userId;
  final String contentId;
  final bool isRecording;
  const RestoreHistoryItem({
    required this.userId,
    required this.contentId,
    this.isRecording = false,
  });

  @override
  List<Object?> get props => [userId, contentId, isRecording];
}