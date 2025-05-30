// File: lib/features/chat/domain/usecases/send_message.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart'; // Sesuaikan path
import 'package:olivia/core/usecases/usecase.dart'; // Sesuaikan path
import 'package:olivia/features/chat/domain/entities/message.dart'; // Sesuaikan path
import 'package:olivia/features/chat/domain/repositories/chat_repository.dart'; // Sesuaikan path

class SendMessage implements UseCase<MessageEntity, SendMessageParams> {
  final ChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) async {
    if (params.content.trim().isEmpty) {
      return Left(InputValidationFailure("Pesan tidak boleh kosong."));
    }
    if (params.chatRoomId.isEmpty || params.senderId.isEmpty) {
      return Left(InputValidationFailure("Informasi pengiriman tidak lengkap."));
    }
    return await repository.sendMessage(
      chatRoomId: params.chatRoomId,
      senderId: params.senderId,
      content: params.content,
      itemId: params.itemId,
    );
  }
}

class SendMessageParams extends Equatable { // PASTIKAN KELAS INI ADA
  final String chatRoomId;
  final String senderId;
  final String content;
  final String? itemId;

  const SendMessageParams({
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    this.itemId,
  });

  @override
  List<Object?> get props => [chatRoomId, senderId, content, itemId];
}