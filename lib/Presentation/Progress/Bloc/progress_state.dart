import 'package:equatable/equatable.dart';

import '../../../Domain/Entities/progress_entity.dart';

/// Load status for progress and history.
enum ProgressStatus { initial, loading, loaded, error }

/// State for the progress dashboard and the watch-history page.
class ProgressState extends Equatable {
  final ProgressStatus status;

  /// Per-course weighted progress (video 40 / quiz 15 / exam 15 / live 20 /
  /// attendance 10).
  final List<CourseProgressEntity> courseProgress;

  /// Watch history, newest first.
  final List<WatchHistoryItemEntity> history;

  /// True when hidden items should be included in the list.
  final bool showHidden;

  final String? errorMessage;

  const ProgressState({
    this.status = ProgressStatus.initial,
    this.courseProgress = const [],
    this.history = const [],
    this.showHidden = false,
    this.errorMessage,
  });

  /// History entries that are still visible.
  List<WatchHistoryItemEntity> get visibleHistory =>
      history.where((h) => !h.isHidden).toList();

  /// History entries the student has removed (restorable).
  List<WatchHistoryItemEntity> get hiddenHistory =>
      history.where((h) => h.isHidden).toList();

  /// The list the UI should render, respecting the toggle.
  List<WatchHistoryItemEntity> get displayedHistory =>
      showHidden ? history : visibleHistory;

  /// Average progress across every enrolled course, 0–100.
  double get averageProgress {
    if (courseProgress.isEmpty) return 0;
    final total = courseProgress.fold<double>(
      0,
      (sum, p) => sum + p.effectiveOverall,
    );
    return total / courseProgress.length;
  }

  ProgressState copyWith({
    ProgressStatus? status,
    List<CourseProgressEntity>? courseProgress,
    List<WatchHistoryItemEntity>? history,
    bool? showHidden,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProgressState(
      status: status ?? this.status,
      courseProgress: courseProgress ?? this.courseProgress,
      history: history ?? this.history,
      showHidden: showHidden ?? this.showHidden,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, courseProgress, history, showHidden, errorMessage];
}