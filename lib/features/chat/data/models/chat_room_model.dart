import 'package:olivia/core/utils/enums.dart'; // Ganti 'olivia'
import 'package:olivia/features/auth/domain/entities/user_profile.dart'; // Ganti 'olivia'
import 'package:olivia/features/chat/data/models/message_model.dart'; // Ganti 'olivia'
import 'package:olivia/features/chat/domain/entities/chat_room.dart'; // Ganti 'olivia'
import 'package:olivia/features/chat/domain/entities/message.dart'; // Ganti 'olivia'


// Asumsikan userRoleFromString sudah didefinisikan di tempat lain atau di sini
UserRole userRoleFromString(String roleString) {
  if (roleString.toLowerCase() == 'mahasiswa') return UserRole.mahasiswa;
  if (roleString.toLowerCase() == 'staff/dosen' || roleString.toLowerCase() == 'staff_dosen') return UserRole.staff_dosen; // Sesuaikan dengan string di DB
  print("Warning: Unrecognized role string '$roleString', defaulting to mahasiswa.");
  return UserRole.mahasiswa; // Default atau lempar error jika lebih baik
}


class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.id,
    super.itemId,
    required super.createdAt,
    required super.lastMessageAt,
    required super.participants,
    super.lastMessage,
    super.unreadCount = 0,
    super.otherParticipantName,
    super.otherParticipantAvatarUrl,
    super.otherParticipantId,
  });

  factory ChatRoomModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    try {
      print('🟡 [ChatRoomModel] Parsing JSON: $json');

      final String id = json['id']?.toString() ?? ''; // Ini adalah chat_room_id
      if (id.isEmpty) {
        throw Exception('Chat room ID is null or empty');
      }

      final List<dynamic> participantsRaw =
          json['chat_participants'] as List<dynamic>? ?? [];
      if (participantsRaw.isEmpty) {
        // Bisa jadi chat room baru belum ada partisipan lain selain current user di data awal,
        // atau query select tidak mengembalikan partisipan.
        // Tergantung logika, ini bisa jadi error atau state valid.
        // Untuk sekarang, kita anggap minimal ada 1 partisipan (current user) jika query benar.
        // Jika query Anda `chat_participants!inner`, seharusnya tidak kosong jika room ada.
        print('Warning: Chat participants data is empty for room ID: $id. JSON: $json');
        // throw Exception('Chat participants data is empty'); // Mungkin terlalu ketat jika room baru
      }

      final List<UserProfile> participants = participantsRaw.map((p) {
        final profileData = p['profiles'] as Map<String, dynamic>?; // Cast ke Map
        if (profileData == null) {
          throw Exception('Profile data is null for participant in room ID: $id');
        }

        String roleStringFromJson = profileData['role']?.toString() ?? 'mahasiswa';
        
        final participantId = profileData['id']?.toString();
        if (participantId == null || participantId.isEmpty) {
          throw Exception('Participant ID is null or empty in profileData for room ID: $id');
        }

        return UserProfile(
          id: participantId,
          email: profileData['email']?.toString() ?? '',
          fullName: profileData['full_name']?.toString() ?? 'Unknown User',
          avatarUrl: profileData['avatar_url']?.toString(),
          role: userRoleFromString(roleStringFromJson),
          nim: profileData['nim']?.toString(),
          major: profileData['major']?.toString(),
        );
      }).toList();
      
      // Pastikan ada partisipan setelah parsing
      if (participants.isEmpty && participantsRaw.isNotEmpty) {
          throw Exception('Failed to parse any participants, though raw data existed for room ID: $id.');
      }


      UserProfile otherParticipant;
      if (participants.length == 1 && participants.first.id == currentUserId) {
        // Kasus di mana hanya ada current user sebagai partisipan (misalnya room baru dibuat,
        // atau query hanya mengembalikan current user).
        // Ini perlu penanganan khusus atau pastikan query selalu mengembalikan semua partisipan.
        // Untuk sementara, kita bisa set otherParticipant ke current user itu sendiri
        // atau handle dengan nilai default/null jika UI bisa menanganinya.
        print("Warning: Only current user found as participant for room ID: $id. Setting otherParticipant to current user or default.");
        otherParticipant = participants.first; // Atau UserProfile default/placeholder
      } else if (participants.isEmpty) {
        // Ini seharusnya tidak terjadi jika participantsRaw tidak kosong dan parsing berhasil.
        // Jika terjadi, berarti ada masalah serius dalam parsing participant.
        // Atau jika participantsRaw memang kosong, maka ini adalah kasus khusus.
        throw Exception('No participants parsed for room ID: $id, cannot determine otherParticipant.');
      }
      else {
        otherParticipant = participants.firstWhere(
          (p) => p.id != currentUserId,
          // orElse: () => participants.first, // Fallback ini bisa salah jika hanya ada 1 partisipan yaitu currentUser
                                              // atau jika participants list kosong.
          orElse: () {
            // Jika tidak ada other participant (misalnya, room hanya dengan diri sendiri, atau data tidak lengkap)
            // Kembalikan UserProfile placeholder atau lempar error jika ini tidak valid.
            print("Warning: Could not find other participant for room ID: $id. Defaulting or using first participant.");
            return participants.isNotEmpty ? participants.first : UserProfile(id: 'unknown', email: '', fullName: 'Unknown', role: UserRole.mahasiswa); // Placeholder
          }
        );
      }


      MessageEntity? lastMessage;
      final messagesRaw = json['chat_messages'] as List<dynamic>? ?? [];
      if (messagesRaw.isNotEmpty) {
        messagesRaw.sort((a, b) {
          final aTime =
              DateTime.tryParse(a['sent_at']?.toString() ?? '') ??
              DateTime(1970);
          final bTime =
              DateTime.tryParse(b['sent_at']?.toString() ?? '') ??
              DateTime(1970);
          return bTime.compareTo(aTime); // Terbaru dulu
        });
        // Panggil MessageModel.fromJson dengan chatRoomId (yaitu 'id' dari ChatRoomModel ini)
        lastMessage = MessageModel.fromJson(messagesRaw.first as Map<String, dynamic>, id);
      }

      final createdAt =
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now();
      final lastMessageAt =
          DateTime.tryParse(json['last_message_at']?.toString() ?? '') ??
          createdAt;

      final result = ChatRoomModel(
        id: id,
        itemId: json['item_id']?.toString(),
        createdAt: createdAt,
        lastMessageAt: lastMessageAt,
        participants: participants,
        lastMessage: lastMessage,
        unreadCount: json['unread_count'] as int? ?? 0,
        otherParticipantName: otherParticipant.fullName,
        otherParticipantAvatarUrl: otherParticipant.avatarUrl,
        otherParticipantId: otherParticipant.id,
      );

      print('🟢 [ChatRoomModel] Parse success: ${result.id}');
      return result;
    } catch (e, stackTrace) { // Tambahkan stackTrace untuk debug lebih lanjut
      print('🔴 [ChatRoomModel] Parse error: $e');
      print('🔴 [ChatRoomModel] StackTrace: $stackTrace'); // Cetak stack trace
      print('🔴 [ChatRoomModel] JSON data: $json');
      throw Exception('Failed to parse ChatRoomModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    // ... toJson method Anda ...
    return {
      'id': id,
      'item_id': itemId,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt.toIso8601String(),
      // participants dan lastMessage biasanya tidak dikirim balik sebagai JSON sederhana
      'unread_count': unreadCount,
      // otherParticipant fields juga biasanya tidak dikirim balik
    };
  }
}
