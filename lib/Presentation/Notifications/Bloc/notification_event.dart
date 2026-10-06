import 'package:equatable/equatable.dart';

/// Base class for notification and announcement events.
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the notification list and the unread badge count.
class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

/// Loads the unread badge count only (cheap refresh for the bell icon).
class RefreshUnreadCount extends NotificationEvent {
  const RefreshUnreadCount();
}

/// Marks a single notification as read.
class MarkNotificationRead extends NotificationEvent {
  final String id;
  const MarkNotificationRead(this.id);

  @override
  List<Object?> get props => [id];
}

/// Marks every notification as read.
class MarkAllNotificationsRead extends NotificationEvent {
  const MarkAllNotificationsRead();
}

/// Loads active site-wide announcements (Manual §4.5).
class LoadAnnouncements extends NotificationEvent {
  const LoadAnnouncements();
}