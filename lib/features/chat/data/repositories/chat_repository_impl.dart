import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:olivia/features/chat/domain/entities/chat_room.dart';
import 'package:olivia/features/chat/domain/entities/message.dart';
import 'package:olivia/features/chat/domain/repositories/chat_repository.dart';
// import 'package:olivia/core/network/network_info.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });

  @override
  Stream<Either<Failure, List<ChatRoomEntity>>> getChatRooms(String userId) {
    // if (await networkInfo.isConnected) { // Cek koneksi tidak bisa async di return stream
    try {
      return remoteDataSource.getChatRooms(userId).map((chatRoomModels) {
        return Right<Failure, List<ChatRoomEntity>>(chatRoomModels);
      }).handleError((error) {
        // Tangani error dari stream
        if (error is ServerException) {
          return Left<Failure, List<ChatRoomEntity>>(ServerFailure(error.message));
        }
        return Left<Failure, List<ChatRoomEntity>>(UnknownFailure("Stream error: ${error.toString()}"));
      });
    } catch (e) {
      // Error saat inisialisasi stream
      return Stream.value(Left(ServerFailure("Failed to initialize chat rooms stream: ${e.toString()}")));
    }
    // } else {
    //   return Stream.value(Left(NetworkFailure("No internet connection")));
    // }
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
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
    String? itemId,
  }) async {
    // if (await networkInfo.isConnected) {
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
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, ChatRoomEntity>> createOrGetChatRoom({
    required String currentUserId,
    required String otherUserId,
    String? itemId,
  }) async {
    // if (await networkInfo.isConnected) {
      try {
        final chatRoomModel = await remoteDataSource.createOrGetChatRoom(
          currentUserId: currentUserId,
          otherUserId: otherUserId,
          itemId: itemId,
        );
        return Right(chatRoomModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure("An unexpected error occurred: ${e.toString()}"));
      }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(String chatRoomId, String userId) async {
    // if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markMessagesAsRead(chatRoomId, userId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure("An unexpected error occurred: ${e.toString()}"));
      }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }
}