import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Domain/Repositories/learning_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// Drives the notification bell and the announcements page.
///
/// Manual §4.5: notifications *"refresh every 30 seconds"* and are **in-app
/// only** — *"no email or phone push is sent"*. [RefreshUnreadCount] exists so
/// the periodic poll only transfers a single integer instead of the whole list.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final LearningRepository repository;

  NotificationBloc({required this.repository})
      : super(const NotificationState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshUnreadCount>(_onRefreshUnreadCount);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
    on<LoadAnnouncements>(_onLoadAnnouncements);
  }

  /// Loads the full list and the unread count together.
  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading, clearError: true));

    final listResult = await repository.getMyNotifications();
    final countResult = await repository.getUnreadNotificationCount();

    String? error;
    final notifications = listResult.fold(
      (failure) {
        error = failure.message;
        return state.notifications;
      },
      (value) => value,
    );
    final unread = countResult.fold(
      (_) => state.unreadCount,
      (value) => value,
    );

    emit(state.copyWith(
      status: error != null ? NotificationStatus.error : NotificationStatus.loaded,
      notifications: notifications,
      unreadCount: unread,
      errorMessage: error,
    ));
  }

  /// Refreshes only the badge count — a deliberately tiny payload for the
  /// 30-second poll.
  Future<void> _onRefreshUnreadCount(
    RefreshUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.getUnreadNotificationCount();
    result.fold(
      (_) {}, // A failed badge refresh is silent — never disturb the UI.
      (count) => emit(state.copyWith(unreadCount: count)),
    );
  }

  Future<void> _onMarkRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.markNotificationRead(event.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        // Update locally so the list does not need a full reload.
        final updated = state.notifications
            .map((n) => n.id == event.id ? n.copyWith(isRead: true) : n)
            .toList();
        final newUnread = updated.where((n) => !n.isRead).length;
        emit(state.copyWith(notifications: updated, unreadCount: newUnread));
      },
    );
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.markAllNotificationsRead();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final updated = state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        emit(state.copyWith(notifications: updated, unreadCount: 0));
      },
    );
  }

  Future<void> _onLoadAnnouncements(
    LoadAnnouncements event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.getActiveAnnouncements();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (announcements) => emit(state.copyWith(announcements: announcements)),
    );
  }
}