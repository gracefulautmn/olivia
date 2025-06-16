import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/chat/domain/entities/chat_room.dart';
import 'package:olivia/features/chat/domain/repositories/chat_repository.dart';

class CreateOrGetChatRoom implements UseCase<ChatRoomEntity, CreateOrGetChatRoomParams> {
  final ChatRepository repository;

  CreateOrGetChatRoom(this.repository);

  @override
  Future<Either<Failure, ChatRoomEntity>> call(CreateOrGetChatRoomParams params) {
    // Cukup teruskan objek params ke repository
    return repository.createOrGetChatRoom(params);
  }
}

class CreateOrGetChatRoomParams extends Equatable {
  final String? chatRoomId;
  final String currentUserId;
  final String? otherUserId;
  final String? itemId;

  const CreateOrGetChatRoomParams({
    this.chatRoomId,
    required this.currentUserId,
    this.otherUserId,
    this.itemId,
  });

  @override
  List<Object?> get props => [chatRoomId, currentUserId, otherUserId, itemId];
}
