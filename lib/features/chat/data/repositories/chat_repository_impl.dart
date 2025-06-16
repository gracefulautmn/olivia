import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:olivia/features/chat/domain/entities/chat_room.dart';
import 'package:olivia/features/chat/domain/entities/message.dart';
import 'package:olivia/features/chat/domain/repositories/chat_repository.dart';
// Impor params dari use case
import 'package:olivia/features/chat/domain/usecases/create_or_get_chat_room.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  // PERBAIKAN: Implementasi metode baru
  @override
  Future<Either<Failure, ChatRoomEntity>> createOrGetChatRoom(CreateOrGetChatRoomParams params) async {
    try {
      // Logika dipindahkan ke sini
      // Datasource akan dipanggil dengan parameter yang sesuai
      final chatRoomModel = await remoteDataSource.createOrGetChatRoom(
        chatRoomId: params.chatRoomId,
        currentUserId: params.currentUserId,
        otherUserId: params.otherUserId,
        itemId: params.itemId,
      );
      return Right(chatRoomModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure("An unexpected error occurred: ${e.toString()}"));
    }
  }

  // ... (implementasi metode lain seperti getChatRooms, sendMessage, dll. tetap sama)
  
  @override
  Stream<Either<Failure, List<ChatRoomEntity>>> getChatRooms(String userId) {
    try {
      return remoteDataSource.getChatRooms(userId).map((chatRoomModels) {
        return Right<Failure, List<ChatRoomEntity>>(chatRoomModels);
      }).handleError((error) {
        if (error is ServerException) {
          return Left<Failure, List<ChatRoomEntity>>(ServerFailure(error.message));
        }
        return Left<Failure, List<ChatRoomEntity>>(UnknownFailure("Stream error: ${error.toString()}"));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure("Failed to initialize chat rooms stream: ${e.toString()}")));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String chatRoomId, {DateTime? olderThan}) {
     try {
      return remoteDataSource.getMessages(chatRoomId, olderThan: olderThan).map((messageModels) {
        return Right<Failure, List<MessageEntity>>(messageModels);
      }).handleError((error) {
        if (error is ServerException) {
          return Left<Failure, List<MessageEntity>>(ServerFailure(error.message));
        }
        return Left<Failure, List<MessageEntity>>(UnknownFailure("Stream error: ${error.toString()}"));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure("Failed to initialize messages stream: ${e.toString()}")));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({required String chatRoomId, required String senderId, required String content, String? itemId}) async {
    try {
        final messageModel = await remoteDataSource.sendMessage(
          chatRoomId: chatRoomId,
          senderId: senderId,
          content: content,
          itemId: itemId,
        );
        return Right(messageModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure("An unexpected error occurred: ${e.toString()}"));
      }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(String chatRoomId, String userId) async {
     try {
        await remoteDataSource.markMessagesAsRead(chatRoomId, userId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure("An unexpected error occurred: ${e.toString()}"));
      }
  }
}
