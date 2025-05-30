import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, chatRoomId, senderId, content, sentAt, isRead];
}