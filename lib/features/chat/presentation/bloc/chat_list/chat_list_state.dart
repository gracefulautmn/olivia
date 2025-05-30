part of 'chat_list_bloc.dart';

enum ChatListStatus { initial, loading, loaded, failure }

class ChatListState extends Equatable {
  final ChatListStatus status;
  final List<ChatRoomEntity> chatRooms;
  final Failure? failure;

  const ChatListState({
    this.status = ChatListStatus.initial,
    this.chatRooms = const [],
    this.failure,
  });

  ChatListState copyWith({
    ChatListStatus? status,
    List<ChatRoomEntity>? chatRooms,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ChatListState(
      status: status ?? this.status,
      chatRooms: chatRooms ?? this.chatRooms,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, chatRooms, failure];
}