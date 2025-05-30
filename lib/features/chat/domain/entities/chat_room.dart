import 'package:equatable/equatable.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/chat/domain/entities/message.dart'; // Untuk last message

class ChatRoomEntity extends Equatable {
  final String id;
  final String? itemId; // Opsional, jika chat terkait item tertentu
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<UserProfile> participants; // UserProfile dari peserta
  final MessageEntity? lastMessage; // Pesan terakhir untuk preview di list chat
  final int unreadCount; // Jumlah pesan belum dibaca untuk user saat ini

  // Tambahan untuk UI, nama dan avatar lawan bicara
  final String? otherParticipantName;
  final String? otherParticipantAvatarUrl;
  final String? otherParticipantId;

  const ChatRoomEntity({
    required this.id,
    this.itemId,
    required this.createdAt,
    required this.lastMessageAt,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    this.otherParticipantName,
    this.otherParticipantAvatarUrl,
    this.otherParticipantId,
  });

  @override
  List<Object?> get props => [
    id,
    itemId,
    createdAt,
    lastMessageAt,
    participants,
    lastMessage,
    unreadCount,
    otherParticipantName,
    otherParticipantAvatarUrl,
    otherParticipantId,
  ];
}
