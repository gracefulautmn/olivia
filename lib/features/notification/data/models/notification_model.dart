import 'package:olivia/features/notification/domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    required super.title,
    required super.body,
    super.type,
    super.relatedItemId,
    super.relatedChatId,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipient_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String?,
      relatedItemId: json['related_item_id'] as String?,
      relatedChatId: json['related_chat_id'] as String?,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // toJson tidak terlalu relevan karena notifikasi biasanya dibuat oleh sistem/backend
  // Namun, bisa berguna untuk update is_read
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'is_read': isRead,
    };
  }
}