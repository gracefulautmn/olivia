import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/chat/domain/entities/message.dart';
import 'package:olivia/features/chat/domain/repositories/chat_repository.dart';

class GetMessages {
  // Tidak implements UseCase karena return Stream
  final ChatRepository repository;

  GetMessages(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(GetMessagesParams params) {
    if (params.chatRoomId.isEmpty) {
      return Stream.value(
        Left(InputValidationFailure("Chat Room ID tidak valid.")),
      );
    }
    return repository.getMessages(
      params.chatRoomId,
      olderThan: params.olderThan,
    );
  }
}

class GetMessagesParams extends Equatable {
  final String chatRoomId;
  final DateTime? olderThan; // Untuk pagination

  const GetMessagesParams({required this.chatRoomId, this.olderThan});

  @override
  List<Object?> get props => [chatRoomId, olderThan];
}
