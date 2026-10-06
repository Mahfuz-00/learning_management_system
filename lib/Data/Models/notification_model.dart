import '../../Domain/Entities/notification_entity.dart';
import 'json_utils.dart';

/// JSON mapping for an in-app notification (Manual §4.5).
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    super.message,
    super.actionUrl,
    super.isRead,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: JsonUtils.toStringValue(json['id'] ?? json['notificationId']),
      title: JsonUtils.toStringValue(
        json['title'],
        fallback: 'Notification',
      ),
      message: JsonUtils.toStringOrNull(json['message'] ?? json['body']),
      actionUrl: JsonUtils.toStringOrNull(json['actionUrl'] ?? json['link']),
      isRead: JsonUtils.toBool(json['isRead']),
      createdAt: JsonUtils.toDate(json['createdAt'] ?? json['sentAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'actionUrl': actionUrl,
        'isRead': isRead,
        'createdAt': createdAt?.toIso8601String(),
      };
}

/// JSON mapping for a site-wide announcement (Manual §4.5).
class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.title,
    super.body,
    super.expiresAt,
    super.publishedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: JsonUtils.toStringValue(json['id'] ?? json['announcementId']),
      title: JsonUtils.toStringValue(json['title'], fallback: 'Announcement'),
      body: JsonUtils.toStringOrNull(json['body'] ?? json['message'] ?? json['content']),
      expiresAt: JsonUtils.toDate(json['expiresAt'] ?? json['expiryDate']),
      publishedAt: JsonUtils.toDate(json['publishedAt'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'expiresAt': expiresAt?.toIso8601String(),
        'publishedAt': publishedAt?.toIso8601String(),
      };
}