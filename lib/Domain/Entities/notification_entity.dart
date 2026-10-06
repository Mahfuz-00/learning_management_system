import 'package:equatable/equatable.dart';

/// A single in-app notification shown under the bell icon.
///
/// Manual §4.5: *"Refreshes every 30 seconds. These are in-app only — **no
/// email or phone push is sent** for live classes."*
class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String? message;

  /// Optional deep-link target, e.g. `live-class/abc123`.
  final String? actionUrl;

  final bool isRead;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    this.message,
    this.actionUrl,
    this.isRead = false,
    this.createdAt,
  });

  /// Returns a copy with selected fields replaced.
  ///
  /// Used by the notifications BLoC to flip `isRead` locally so the list does
  /// not need a full network reload after a single tap.
  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    String? actionUrl,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      actionUrl: actionUrl ?? this.actionUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Relative label such as "5m ago" for the notification list.
  String get relativeTime {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  @override
  List<Object?> get props => [id, title, message, actionUrl, isRead, createdAt];
}

/// A site-wide notice published by admin.
///
/// Manual §4.5: *"Public notices from admin. They expire automatically on a
/// date admin sets."*
class AnnouncementEntity extends Equatable {
  final String id;
  final String title;
  final String? body;
  final DateTime? expiresAt;
  final DateTime? publishedAt;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    this.body,
    this.expiresAt,
    this.publishedAt,
  });

  /// True when the announcement has passed its expiry date.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  @override
  List<Object?> get props => [id, title, body, expiresAt, publishedAt];
}