import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/chat/domain/entities/chat_room.dart';
import 'package:olivia/features/chat/domain/entities/message.dart';
// Impor params dari use case
import 'package:olivia/features/chat/domain/usecases/create_or_get_chat_room.dart';

abstract class ChatRepository {
  Stream<Either<Failure, List<ChatRoomEntity>>> getChatRooms(String userId);
  
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String chatRoomId, {DateTime? olderThan});

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
    String? itemId,
  });

  // PERBAIKAN: Metode ini sekarang menerima objek Params yang fleksibel
  Future<Either<Failure, ChatRoomEntity>> createOrGetChatRoom(CreateOrGetChatRoomParams params);

  Future<Either<Failure, void>> markMessagesAsRead(String chatRoomId, String userId);
}
