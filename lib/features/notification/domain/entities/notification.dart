import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String recipientId; // User ID penerima notifikasi
  final String title;
  final String body;
  final String? type; // Misal: 'item_match', 'claim_received', 'new_message'
  final String? relatedItemId; // Jika notif terkait item
  final String? relatedChatId; // Jika notif terkait chat
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.body,
    this.type,
    this.relatedItemId,
    this.relatedChatId,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        recipientId,
        title,
        body,
        type,
        relatedItemId,
        relatedChatId,
        isRead,
        createdAt,
      ];
}