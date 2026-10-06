import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Domain/Repositories/learning_repository.dart';
import 'progress_event.dart';
import 'progress_state.dart';

/// Drives the progress dashboard and the watch-history page.
///
/// Manual §4.3: progress is *"one combined number: video 40%, quiz 15%, exam
/// 15%, live exam 20%, attendance 10%"*, and watch history behaves *"like
/// YouTube history"* where removing an item only hides it.
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final LearningRepository repository;

  ProgressBloc({required this.repository}) : super(const ProgressState()) {
    on<LoadMyProgress>(_onLoadProgress);
    on<LoadWatchHistory>(_onLoadHistory);
    on<HideHistoryItem>(_onHideItem);
    on<RestoreHistoryItem>(_onRestoreItem);
  }

  Future<void> _onLoadProgress(
    LoadMyProgress event,
    Emitter<ProgressState> emit,
  ) async {
    emit(state.copyWith(status: ProgressStatus.loading, clearError: true));
    final result = await repository.getMyProgress();
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProgressStatus.error,
        errorMessage: failure.message,
      )),
      (progress) => emit(state.copyWith(
        status: ProgressStatus.loaded,
        courseProgress: progress,
      )),
    );
  }

  Future<void> _onLoadHistory(
    LoadWatchHistory event,
    Emitter<ProgressState> emit,
  ) async {
    emit(state.copyWith(status: ProgressStatus.loading, clearError: true));
    final result = await repository.getWatchHistory(event.userId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProgressStatus.error,
        errorMessage: failure.message,
      )),
      (history) {
        // Newest first, matching the "like YouTube history" requirement.
        final sorted = [...history]
          ..sort((a, b) {
            final aDate = a.lastWatchedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.lastWatchedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });
        emit(state.copyWith(status: ProgressStatus.loaded, history: sorted));
      },
    );
  }

  /// Hides an item. The server keeps the progress intact, so this is reversible.
  Future<void> _onHideItem(
    HideHistoryItem event,
    Emitter<ProgressState> emit,
  ) async {
    final result = await repository.hideWatchHistoryItem(
      event.userId,
      event.contentId,
      isRecording: event.isRecording,
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final updated = state.history
            .map((h) => h.contentId == event.contentId
                ? h.copyWithHidden(true)
                : h)
            .toList();
        emit(state.copyWith(history: updated));
      },
    );
  }

  /// Restores a hidden item.
  Future<void> _onRestoreItem(
    RestoreHistoryItem event,
    Emitter<ProgressState> emit,
  ) async {
    final result = await repository.restoreWatchHistoryItem(
      event.userId,
      event.contentId,
      isRecording: event.isRecording,
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final updated = state.history
            .map((h) => h.contentId == event.contentId
                ? h.copyWithHidden(false)
                : h)
            .toList();
        emit(state.copyWith(history: updated));
      },
    );
  }
}