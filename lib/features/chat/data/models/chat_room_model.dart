import 'package:olivia/features/auth/data/models/user_profile_model.dart';
import 'package:olivia/features/chat/data/models/message_model.dart';
import 'package:olivia/features/chat/domain/entities/chat_room.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.id,
    super.itemId,
    required super.createdAt,
    required super.lastMessageAt,
    required List<UserProfileModel>
    super.participants, // Pastikan tipenya Model
    super.lastMessage, // Bisa MessageModel
    super.unreadCount,
    super.otherParticipantName,
    super.otherParticipantAvatarUrl,
    super.otherParticipantId,
  });

  factory ChatRoomModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    var participantModels = <UserProfileModel>[];
    if (json['chat_participants'] != null) {
      participantModels =
          (json['chat_participants'] as List)
              .map(
                (p) => UserProfileModel.fromJson(
                  p['profiles'] as Map<String, dynamic>,
                ),
              ) // Asumsi 'profiles' adalah hasil join
              .toList();
    }

    // Cari other participant
    UserProfileModel? otherParticipant;
    if (participantModels.length == 2) {
      // Asumsi chat selalu 1-on-1 untuk sekarang
      otherParticipant = participantModels.firstWhere(
        (p) => p.id != currentUserId,
        orElse: () => participantModels.first,
      );
    }

    return ChatRoomModel(
      id: json['id'] as String,
      itemId: json['item_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      participants: participantModels,
      lastMessage:
          json['chat_messages'] != null &&
                  (json['chat_messages'] as List).isNotEmpty
              ? MessageModel.fromJson(
                (json['chat_messages'] as List).first as Map<String, dynamic>,
              ) // Ambil pesan terakhir dari array
              : null,
      // unreadCount perlu dihitung terpisah biasanya, atau dari query khusus
      unreadCount:
          (json['unread_count'] as int?) ?? 0, // Jika ada field ini dari query
      otherParticipantName: otherParticipant?.fullName,
      otherParticipantAvatarUrl: otherParticipant?.avatarUrl,
      otherParticipantId: otherParticipant?.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt.toIso8601String(),
      // participants dan lastMessage tidak di-serialize balik ke DB untuk chat_rooms
    };
  }
}
