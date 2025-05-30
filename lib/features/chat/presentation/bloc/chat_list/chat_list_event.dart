part of 'chat_list_bloc.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object> get props => [];
}

class LoadChatRooms extends ChatListEvent {
  final String userId;
  const LoadChatRooms(this.userId);
   @override
  List<Object> get props => [userId];
}

// Event internal untuk update dari stream
class _ChatRoomsUpdated extends ChatListEvent {
  final Either<Failure, List<ChatRoomEntity>> chatRoomsOrFailure;
  const _ChatRoomsUpdated(this.chatRoomsOrFailure);
   @override
  List<Object> get props => [chatRoomsOrFailure];
}