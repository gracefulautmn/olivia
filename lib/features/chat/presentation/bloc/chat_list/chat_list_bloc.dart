import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/chat/domain/entities/chat_room.dart';
import 'package:olivia/features/chat/domain/usecases/get_chat_rooms.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatRooms _getChatRoomsUseCase;
  StreamSubscription<Either<Failure, List<ChatRoomEntity>>>?
  _chatRoomsSubscription;

  ChatListBloc({required GetChatRooms getChatRoomsUseCase})
    : _getChatRoomsUseCase = getChatRoomsUseCase,
      super(const ChatListState()) {
    on<LoadChatRooms>(_onLoadChatRooms);
    on<_ChatRoomsUpdated>(_onChatRoomsUpdated);
  }

  void _onLoadChatRooms(LoadChatRooms event, Emitter<ChatListState> emit) {
    emit(state.copyWith(status: ChatListStatus.loading, clearFailure: true));
    _chatRoomsSubscription?.cancel(); // Cancel subscription lama jika ada
    _chatRoomsSubscription = _getChatRoomsUseCase(
      GetChatRoomsParams(userId: event.userId),
    ).listen((chatRoomsOrFailure) {
      add(_ChatRoomsUpdated(chatRoomsOrFailure));
    });
  }

  void _onChatRoomsUpdated(
    _ChatRoomsUpdated event,
    Emitter<ChatListState> emit,
  ) {
    event.chatRoomsOrFailure.fold(
      (failure) => emit(
        state.copyWith(status: ChatListStatus.failure, failure: failure),
      ),
      (chatRooms) => emit(
        state.copyWith(
          status: ChatListStatus.loaded,
          chatRooms: chatRooms,
          clearFailure: true,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _chatRoomsSubscription?.cancel();
    return super.close();
  }
}
