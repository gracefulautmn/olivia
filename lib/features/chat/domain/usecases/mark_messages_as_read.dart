import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/chat/domain/repositories/chat_repository.dart';

class MarkMessagesAsRead implements UseCase<void, MarkMessagesAsReadParams> {
  final ChatRepository repository;

  MarkMessagesAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkMessagesAsReadParams params) async {
    if (params.chatRoomId.isEmpty || params.userId.isEmpty) {
      return Left(
        InputValidationFailure("Informasi tidak lengkap untuk menandai pesan."),
      );
    }
    return await repository.markMessagesAsRead(
      params.chatRoomId,
      params.userId,
    );
  }
}

class MarkMessagesAsReadParams extends Equatable {
  final String chatRoomId;
  final String
  userId; // User yang membuka chat (untuk tidak menandai pesannya sendiri sbg read)

  const MarkMessagesAsReadParams({
    required this.chatRoomId,
    required this.userId,
  });

  @override
  List<Object> get props => [chatRoomId, userId];
}
