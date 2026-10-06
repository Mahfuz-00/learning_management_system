import 'package:equatable/equatable.dart';

import '../../../Domain/Entities/notification_entity.dart';

/// Load status for the notifications screen.
enum NotificationStatus { initial, loading, loaded, error }

/// State for notifications and announcements.
class NotificationState extends Equatable {
  final NotificationStatus status;

  /// All notifications, newest first.
  final List<NotificationEntity> notifications;

  /// Unread count for the bell badge.
  final int unreadCount;

  /// Active announcements (Manual §4.5).
  final List<AnnouncementEntity> announcements;

  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.announcements = const [],
    this.errorMessage,
  });

  /// True when the bell should show a badge.
  bool get hasUnread => unreadCount > 0;

  /// Announcements that have not yet expired.
  List<AnnouncementEntity> get activeAnnouncements =>
      announcements.where((a) => !a.isExpired).toList();

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    int? unreadCount,
    List<AnnouncementEntity>? announcements,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      announcements: announcements ?? this.announcements,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, notifications, unreadCount, announcements, errorMessage];
}