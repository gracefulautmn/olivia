import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/chat/domain/entities/chat_room.dart';
import 'package:olivia/features/chat/domain/entities/message.dart';

abstract class ChatRepository {
  // Mendapatkan daftar chat room untuk user saat ini (dengan pesan terakhir & info partisipan lain)
  // Menggunakan Stream untuk real-time updates
  Stream<Either<Failure, List<ChatRoomEntity>>> getChatRooms(String userId);

  // Mendapatkan pesan dalam satu chat room
  // Menggunakan Stream untuk real-time updates pesan baru
  // Parameter `olderThan` bisa digunakan untuk implementasi pagination (load more older messages)
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String chatRoomId, {DateTime? olderThan});

  // Mengirim pesan baru
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
    String? itemId, // Opsional, jika pesan pertama terkait item
  });

  // Membuat atau mendapatkan chat room yang sudah ada antara dua user (dan opsional item)
  // Ini berguna saat memulai chat baru dari detail item atau profil user.
  Future<Either<Failure, ChatRoomEntity>> createOrGetChatRoom({
    required String currentUserId,
    required String otherUserId,
    String? itemId, // Jika chat dimulai dari detail item
  });

  // Menandai semua pesan dalam chat room sebagai sudah dibaca oleh user tertentu
  Future<Either<Failure, void>> markMessagesAsRead(String chatRoomId, String userId);
}