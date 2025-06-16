import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/chat/domain/entities/chat_room.dart';
import 'package:olivia/features/chat/domain/entities/message.dart';
import 'package:olivia/features/chat/domain/usecases/create_or_get_chat_room.dart';
import 'package:olivia/features/chat/domain/usecases/get_messages.dart';
import 'package:olivia/features/chat/domain/usecases/mark_messages_as_read.dart';
import 'package:olivia/features/chat/domain/usecases/send_message.dart';

part 'chat_detail_event.dart';
part 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final CreateOrGetChatRoom _createOrGetChatRoomUseCase;
  final GetMessages _getMessagesUseCase;
  final SendMessage _sendMessageUseCase;
  final MarkMessagesAsRead _markMessagesAsReadUseCase;

  StreamSubscription<Either<Failure, List<MessageEntity>>>? _messagesSubscription;
  String? _currentUserId;

  ChatDetailBloc({
    required CreateOrGetChatRoom createOrGetChatRoomUseCase,
    required GetMessages getMessagesUseCase,
    required SendMessage sendMessageUseCase,
    required MarkMessagesAsRead markMessagesAsReadUseCase,
  })  : _createOrGetChatRoomUseCase = createOrGetChatRoomUseCase,
        _getMessagesUseCase = getMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _markMessagesAsReadUseCase = markMessagesAsReadUseCase,
        super(const ChatDetailState()) {
    on<InitializeChatRoom>(_onInitializeChatRoom);
    on<LoadMessages>(_onLoadMessages);
    on<_MessagesUpdated>(_onMessagesUpdated);
    on<SendNewMessage>(_onSendNewMessage);
    on<MarkAsRead>(_onMarkAsRead);
  }

  Future<void> _onInitializeChatRoom(InitializeChatRoom event, Emitter<ChatDetailState> emit) async {
    print('🟡 [ChatDetailBloc] InitializeChatRoom started');
    print('🟡 [ChatDetailBloc] Parameters: chatRoomId=${event.chatRoomId}, currentUserId=${event.currentUserId}, otherUserId=${event.otherUserId}');
    
    emit(state.copyWith(status: ChatDetailStatus.loadingRoom, recipientName: event.recipientName, clearFailure: true));
    _currentUserId = event.currentUserId;

    // Logika disederhanakan: Cukup panggil use case.
    // Repository yang sekarang bertanggung jawab menangani logika
    // apakah akan membuat room baru atau mengambil yang sudah ada.
    final result = await _createOrGetChatRoomUseCase(CreateOrGetChatRoomParams(
      chatRoomId: event.chatRoomId, // Bisa null jika membuat baru
      currentUserId: event.currentUserId,
      otherUserId: event.otherUserId, // Bisa null jika membuka dari notifikasi
      itemId: event.itemId,
    ));

    result.fold(
      (failure) => emit(state.copyWith(status: ChatDetailStatus.failure, failure: failure)),
      (chatRoom) {
        emit(state.copyWith(status: ChatDetailStatus.roomLoaded, chatRoom: chatRoom));
        add(LoadMessages(chatRoom.id)); // Langsung muat pesan setelah room didapat
        add(const MarkAsRead()); // Tandai pesan sebagai sudah dibaca
      },
    );
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatDetailState> emit) {
    if (state.chatRoom == null || state.chatRoom!.id != event.chatRoomId) return;

    emit(state.copyWith(status: ChatDetailStatus.loadingMessages, clearFailure: true));
    _messagesSubscription?.cancel();
    _messagesSubscription = _getMessagesUseCase(GetMessagesParams(chatRoomId: event.chatRoomId))
        .listen((messagesOrFailure) {
      add(_MessagesUpdated(messagesOrFailure));
    });
  }

  void _onMessagesUpdated(_MessagesUpdated event, Emitter<ChatDetailState> emit) {
    event.messagesOrFailure.fold(
      (failure) => emit(state.copyWith(status: ChatDetailStatus.failure, failure: failure)),
      (messages) {
        emit(state.copyWith(status: ChatDetailStatus.messagesLoaded, messages: messages, clearFailure: true));
        // Setelah pesan baru diterima, tandai lagi sebagai sudah dibaca
        if (messages.isNotEmpty && messages.any((m) => m.senderId != _currentUserId && !m.isRead)) {
           add(const MarkAsRead());
        }
      }
    );
  }

  Future<void> _onSendNewMessage(SendNewMessage event, Emitter<ChatDetailState> emit) async {
    if (state.chatRoom == null || _currentUserId == null) {
      emit(state.copyWith(status: ChatDetailStatus.sendMessageFailure, failure: const InputValidationFailure("Chat room atau user tidak valid.")));
      return;
    }

    emit(state.copyWith(status: ChatDetailStatus.sendingMessage, clearFailure: true));
    final result = await _sendMessageUseCase(SendMessageParams(
      chatRoomId: state.chatRoom!.id,
      senderId: _currentUserId!,
      content: event.content,
      itemId: state.chatRoom!.itemId,
    ));

    result.fold(
      (failure) => emit(state.copyWith(status: ChatDetailStatus.sendMessageFailure, failure: failure)),
      (message) {
        emit(state.copyWith(status: ChatDetailStatus.sendMessageSuccess));
        // State messages akan diupdate oleh stream _MessagesUpdated
      },
    );
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<ChatDetailState> emit) async {
    if (state.chatRoom != null && _currentUserId != null) {
      await _markMessagesAsReadUseCase(MarkMessagesAsReadParams(
        chatRoomId: state.chatRoom!.id,
        userId: _currentUserId!,
      ));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
