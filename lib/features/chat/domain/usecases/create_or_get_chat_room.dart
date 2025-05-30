import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/chat/domain/entities/chat_room.dart';
import 'package:olivia/features/chat/domain/repositories/chat_repository.dart';

class CreateOrGetChatRoom
    implements UseCase<ChatRoomEntity, CreateOrGetChatRoomParams> {
  final ChatRepository repository;

  CreateOrGetChatRoom(this.repository);

  @override
  Future<Either<Failure, ChatRoomEntity>> call(
    CreateOrGetChatRoomParams params,
  ) async {
    if (params.currentUserId.isEmpty || params.otherUserId.isEmpty) {
      return Left(AuthFailure("User ID tidak valid."));
    }
    if (params.currentUserId == params.otherUserId) {
      return Left(
        InputValidationFailure("Tidak bisa membuat chat dengan diri sendiri."),
      );
    }
    return await repository.createOrGetChatRoom(
      currentUserId: params.currentUserId,
      otherUserId: params.otherUserId,
      itemId: params.itemId,
    );
  }
}

class CreateOrGetChatRoomParams extends Equatable {
  final String currentUserId;
  final String otherUserId;
  final String? itemId;

  const CreateOrGetChatRoomParams({
    required this.currentUserId,
    required this.otherUserId,
    this.itemId,
  });

  @override
  List<Object?> get props => [currentUserId, otherUserId, itemId];
}
