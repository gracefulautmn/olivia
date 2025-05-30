import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
// import 'package:olivia/core/usecases/usecase.dart'; // Tidak pakai UseCase<Type, Params> untuk stream
import 'package:olivia/features/chat/domain/entities/chat_room.dart';
import 'package:olivia/features/chat/domain/repositories/chat_repository.dart';

class GetChatRooms {
  // Tidak implements UseCase karena return Stream
  final ChatRepository repository;

  GetChatRooms(this.repository);

  Stream<Either<Failure, List<ChatRoomEntity>>> call(
    GetChatRoomsParams params,
  ) {
    if (params.userId.isEmpty) {
      return Stream.value(Left(AuthFailure("User ID tidak valid.")));
    }
    return repository.getChatRooms(params.userId);
  }
}

class GetChatRoomsParams extends Equatable {
  final String userId;

  const GetChatRoomsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
