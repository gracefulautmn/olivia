part of 'chat_detail_bloc.dart';

enum ChatDetailStatus { initial, loadingRoom, roomLoaded, loadingMessages, messagesLoaded, sendingMessage, sendMessageSuccess, sendMessageFailure, failure }

class ChatDetailState extends Equatable {
  final ChatDetailStatus status;
  final ChatRoomEntity? chatRoom;
  final List<MessageEntity> messages;
  final Failure? failure;
  final String recipientName; // Untuk ditampilkan di AppBar

  const ChatDetailState({
    this.status = ChatDetailStatus.initial,
    this.chatRoom,
    this.messages = const [],
    this.failure,
    this.recipientName = '',
  });

  ChatDetailState copyWith({
    ChatDetailStatus? status,
    ChatRoomEntity? chatRoom,
    List<MessageEntity>? messages,
    Failure? failure,
    bool clearFailure = false,
    String? recipientName,
  }) {
    return ChatDetailState(
      status: status ?? this.status,
      chatRoom: chatRoom ?? this.chatRoom,
      messages: messages ?? this.messages,
      failure: clearFailure ? null : failure ?? this.failure,
      recipientName: recipientName ?? this.recipientName,
    );
  }

  @override
  List<Object?> get props => [status, chatRoom, messages, failure, recipientName];
}