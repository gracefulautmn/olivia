part of 'chat_detail_bloc.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

// Event untuk memuat chat room (jika ID diketahui) atau membuat/mendapatkan room baru
class InitializeChatRoom extends ChatDetailEvent {
  final String? chatRoomId; // Bisa null jika ini chat baru
  final String currentUserId;
  final String otherUserId;
  final String? itemId; // Opsional, jika chat dari item
  final String recipientName; // Untuk UI

  const InitializeChatRoom({
    this.chatRoomId,
    required this.currentUserId,
    required this.otherUserId,
    this.itemId,
    required this.recipientName,
  });
   @override
  List<Object?> get props => [chatRoomId, currentUserId, otherUserId, itemId, recipientName];
}

class LoadMessages extends ChatDetailEvent {
  final String chatRoomId;
  const LoadMessages(this.chatRoomId);
   @override
  List<Object?> get props => [chatRoomId];
}

// Event internal untuk update dari stream messages
class _MessagesUpdated extends ChatDetailEvent {
  final Either<Failure, List<MessageEntity>> messagesOrFailure;
  const _MessagesUpdated(this.messagesOrFailure);
    @override
  List<Object?> get props => [messagesOrFailure];
}

class SendNewMessage extends ChatDetailEvent {
  final String content;
  const SendNewMessage(this.content);
   @override
  List<Object?> get props => [content];
}

class MarkAsRead extends ChatDetailEvent {
  // Tidak perlu parameter, akan menggunakan chatRoomId dan userId dari state
  const MarkAsRead();
}