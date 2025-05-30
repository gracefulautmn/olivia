import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/features/chat/data/models/chat_room_model.dart';
import 'package:olivia/features/chat/data/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatRoomModel>> getChatRooms(String userId);
  Stream<List<MessageModel>> getMessages(
    String chatRoomId, {
    DateTime? olderThan,
  });
  Future<MessageModel> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
    String? itemId,
  });
  Future<ChatRoomModel> createOrGetChatRoom({
    required String currentUserId,
    required String otherUserId,
    String? itemId,
  });
  Future<void> markMessagesAsRead(String chatRoomId, String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid;

  ChatRemoteDataSourceImpl({required this.supabaseClient})
    : uuid = const Uuid();

  @override
  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    try {
      // Query ini kompleks, perlu join beberapa tabel:
      // 1. chat_participants untuk mendapatkan room_id dimana user adalah partisipan
      // 2. chat_rooms untuk info room (last_message_at)
      // 3. chat_participants lagi (join dengan profiles) untuk info partisipan lain
      // 4. chat_messages untuk pesan terakhir
      // 5. Hitung unread messages
      // Supabase real-time akan memantau perubahan pada `chat_rooms` dan `chat_messages`
      // yang partisipannya adalah `userId`
      final stream = supabaseClient
          .from('chat_rooms')
          .stream(primaryKey: ['id']) // Pantau perubahan di chat_rooms
          .eq(
            'chat_participants.user_id',
            userId,
          ) // Filter room dimana user adalah partisipan
          // .order('last_message_at', ascending: false) // Order tidak bisa langsung di stream utama
          .map((listOfMaps) {
            // Setiap listOfMaps adalah snapshot terbaru dari tabel chat_rooms (yang match filter)
            // Kita perlu query tambahan di sini untuk setiap room untuk mendapatkan detail participants dan last message
            // Ini bisa jadi tidak efisien jika banyak room.
            // Alternatif: Gunakan Supabase Function (Edge Function) untuk pre-process data ini.

            // Untuk simplifikasi, kita fetch semua room user, lalu untuk setiap room, fetch detailnya.
            // Ini TIDAK ideal untuk real-time performa tinggi tapi sebagai contoh awal.
            // Yang lebih baik adalah membuat view di Supabase atau function.

            // Placeholder: Ini hanya akan mengembalikan room yang user ada di dalamnya,
            // tapi tanpa info lengkap seperti otherParticipant dan lastMessage secara efisien
            // hanya dengan stream ini.

            // Seharusnya stream ini memantau perubahan di VIEW yang sudah meng-aggregate data.
            // Misal: CREATE VIEW user_chat_rooms_with_details AS ...
            // supabaseClient.from('user_chat_rooms_with_details').stream(...)

            // Untuk sekarang, kita akan coba query yang lebih lengkap tapi mungkin tidak sepenuhnya real-time efisien
            // untuk semua field tanpa view/function.

            // Ambil semua room ID dimana user adalah partisipan
            return supabaseClient
                .rpc(
                  'get_user_chat_rooms_with_details',
                  params: {'p_user_id': userId},
                )
                .then((response) {
                  if (response is List) {
                    return response
                        .map(
                          (roomData) => ChatRoomModel.fromJson(
                            roomData as Map<String, dynamic>,
                            userId,
                          ),
                        )
                        .toList()
                      ..sort(
                        (a, b) => b.lastMessageAt.compareTo(a.lastMessageAt),
                      ); // Sort client-side
                  }
                  return <ChatRoomModel>[];
                })
                .catchError((error) {
                  print("Error mapping chat rooms from RPC: $error");
                  throw ServerException(
                    message: "Failed to process chat rooms: $error",
                  );
                });
          });

      // Unwrap Future<List<ChatRoomModel>> dari stream
      return stream.asyncMap((futureList) => futureList);
    } catch (e) {
      print("Error getting chat rooms stream: $e");
      // Stream error handling berbeda, biasanya error akan di-emit oleh stream itu sendiri
      // atau kita bisa return Stream.error(...)
      throw ServerException(
        message: "Failed to get chat rooms stream: ${e.toString()}",
      );
    }
  }

  // Supabase Function `get_user_chat_rooms_with_details` (contoh, perlu dibuat di Supabase SQL Editor):
  /*
  CREATE OR REPLACE FUNCTION get_user_chat_rooms_with_details(p_user_id UUID)
  RETURNS TABLE (
      id UUID,
      item_id UUID,
      created_at TIMESTAMPTZ,
      last_message_at TIMESTAMPTZ,
      chat_participants JSONB, -- Array of participant profiles
      chat_messages JSONB, -- Last message
      unread_count INTEGER
  )
  AS $$
  BEGIN
      RETURN QUERY
      SELECT
          cr.id,
          cr.item_id,
          cr.created_at,
          cr.last_message_at,
          (
              SELECT jsonb_agg(jsonb_build_object('profiles', p.*))
              FROM chat_participants cp_inner
              JOIN profiles p ON cp_inner.user_id = p.id
              WHERE cp_inner.chat_room_id = cr.id
          ) AS chat_participants,
          (
              SELECT jsonb_agg(lm.* ORDER BY lm.sent_at DESC LIMIT 1)
              FROM chat_messages lm
              WHERE lm.chat_room_id = cr.id
          ) AS chat_messages,
          (
              SELECT COUNT(*)::INTEGER
              FROM chat_messages nm
              WHERE nm.chat_room_id = cr.id AND nm.sender_id != p_user_id AND nm.is_read = FALSE
          ) AS unread_count
      FROM
          chat_rooms cr
      JOIN
          chat_participants cp ON cr.id = cp.chat_room_id
      WHERE
          cp.user_id = p_user_id
      ORDER BY
          cr.last_message_at DESC;
  END;
  $$ LANGUAGE plpgsql;
  */

  @override
  Stream<List<MessageModel>> getMessages(
    String chatRoomId, {
    DateTime? olderThan,
  }) {
    try {
      // Menggunakan Supabase Realtime untuk pesan baru
      // Untuk pesan lama (pagination), kita akan fetch biasa
      // Ini adalah contoh dasar, pagination bisa lebih kompleks

      // Ambil pesan awal (misal 20 terbaru)
      // Lalu stream untuk pesan baru setelahnya

      // Stream untuk pesan baru yang masuk setelah waktu tertentu (atau semua jika olderThan null)
      var query = supabaseClient
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .eq('chat_room_id', chatRoomId)
          .order('sent_at', ascending: true); // Urutkan dari lama ke baru

      if (olderThan != null) {
        // Ini untuk pagination saat scroll ke atas, ambil pesan SEBELUM olderThan
        // Untuk stream pesan baru, kita ambil yang LEBIH BARU dari pesan terakhir yang sudah ada
        // Logika ini perlu disesuaikan. Untuk stream, kita biasanya ambil semua setelah initial load.
      }

      return query.map((listOfMaps) {
        return listOfMaps
            .map((msgJson) => MessageModel.fromJson(msgJson))
            .toList();
      });
    } catch (e) {
      print("Error getting messages stream: $e");
      throw ServerException(
        message: "Failed to get messages stream: ${e.toString()}",
      );
    }
  }

  Future<List<MessageModel>> getInitialMessages(
    String chatRoomId,
    int limit,
  ) async {
    final response = await supabaseClient
        .from('chat_messages')
        .select()
        .eq('chat_room_id', chatRoomId)
        .order(
          'sent_at',
          ascending: false,
        ) // Ambil terbaru dulu untuk initial load
        .limit(limit);
    return response
        .map((e) => MessageModel.fromJson(e))
        .toList()
        .reversed
        .toList(); // Balik agar urut dari lama ke baru
  }

  @override
  Future<MessageModel> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
    String?
    itemId, // Tidak digunakan langsung saat insert message, tapi bisa untuk update room
  }) async {
    try {
      final messageData = {
        'chat_room_id': chatRoomId,
        'sender_id': senderId,
        'content': content,
        // 'id' dan 'sent_at' akan di-generate oleh DB
      };
      final response =
          await supabaseClient
              .from('chat_messages')
              .insert(messageData)
              .select()
              .single();

      // Update last_message_at di chat_rooms
      await supabaseClient
          .from('chat_rooms')
          .update({'last_message_at': DateTime.now().toIso8601String()})
          .eq('id', chatRoomId);

      return MessageModel.fromJson(response);
    } catch (e) {
      print("Error sending message: $e");
      throw ServerException(message: "Failed to send message: ${e.toString()}");
    }
  }

  @override
  Future<ChatRoomModel> createOrGetChatRoom({
    required String currentUserId,
    required String otherUserId,
    String? itemId,
  }) async {
    try {
      // Panggil RPC function di Supabase untuk handle ini (lebih aman dan efisien)
      // RPC akan cek apakah room sudah ada, jika belum, buat room dan partisipan
      final response =
          await supabaseClient
              .rpc(
                'create_or_get_chat_room',
                params: {
                  'p_user1_id': currentUserId,
                  'p_user2_id': otherUserId,
                  'p_item_id': itemId, // Bisa null
                },
              )
              .single(); // Mengharapkan satu baris data room (JSON)

      // RPC 'create_or_get_chat_room' akan mengembalikan data room yang sudah di-join
      // mirip dengan get_user_chat_rooms_with_details tapi untuk satu room.
      return ChatRoomModel.fromJson(
        response as Map<String, dynamic>,
        currentUserId,
      );
    } catch (e) {
      print("Error creating or getting chat room: $e");
      throw ServerException(
        message: "Failed to create or get chat room: ${e.toString()}",
      );
    }
  }
  // Contoh Supabase Function `create_or_get_chat_room` (perlu dibuat di Supabase SQL Editor)
  /*
  CREATE OR REPLACE FUNCTION create_or_get_chat_room(
      p_user1_id UUID,
      p_user2_id UUID,
      p_item_id UUID DEFAULT NULL
  )
  RETURNS JSONB -- Mengembalikan detail room seperti di get_user_chat_rooms_with_details
  AS $$
  DECLARE
      v_chat_room_id UUID;
      v_existing_room_id UUID;
      v_room_details JSONB;
  BEGIN
      -- Sort user IDs to ensure consistency in finding existing rooms (optional but good practice)
      -- IF p_user1_id > p_user2_id THEN
      --     SELECT p_user1_id, p_user2_id INTO p_user2_id, p_user1_id;
      -- END IF;

      -- Check if a room already exists between these two users (ignoring item_id for now for simplicity)
      -- This query needs to be more robust if item_id also defines uniqueness of a room
      SELECT cr.id INTO v_existing_room_id
      FROM chat_rooms cr
      JOIN chat_participants cp1 ON cr.id = cp1.chat_room_id AND cp1.user_id = p_user1_id
      JOIN chat_participants cp2 ON cr.id = cp2.chat_room_id AND cp2.user_id = p_user2_id
      WHERE (cr.item_id = p_item_id OR (cr.item_id IS NULL AND p_item_id IS NULL)) -- Jika item_id penting untuk unik
      LIMIT 1;

      IF v_existing_room_id IS NOT NULL THEN
          v_chat_room_id := v_existing_room_id;
      ELSE
          -- Create new chat room
          INSERT INTO chat_rooms (item_id) VALUES (p_item_id)
          RETURNING id INTO v_chat_room_id;

          -- Add participants
          INSERT INTO chat_participants (chat_room_id, user_id)
          VALUES (v_chat_room_id, p_user1_id), (v_chat_room_id, p_user2_id);
      END IF;

      -- Fetch and return the room details (similar to get_user_chat_rooms_with_details but for one room)
      SELECT jsonb_build_object(
          'id', cr.id,
          'item_id', cr.item_id,
          'created_at', cr.created_at,
          'last_message_at', cr.last_message_at,
          'chat_participants', (
              SELECT jsonb_agg(jsonb_build_object('profiles', p.*))
              FROM chat_participants cp_inner
              JOIN profiles p ON cp_inner.user_id = p.id
              WHERE cp_inner.chat_room_id = cr.id
          ),
          'chat_messages', (
              SELECT jsonb_agg(lm.* ORDER BY lm.sent_at DESC LIMIT 1)
              FROM chat_messages lm
              WHERE lm.chat_room_id = cr.id
          ),
          'unread_count', (
              SELECT COUNT(*)::INTEGER
              FROM chat_messages nm
              WHERE nm.chat_room_id = cr.id AND nm.sender_id != LEAST(p_user1_id, p_user2_id) AND nm.is_read = FALSE -- Adjust unread logic
          )
      ) INTO v_room_details
      FROM chat_rooms cr
      WHERE cr.id = v_chat_room_id;

      RETURN v_room_details;
  END;
  $$ LANGUAGE plpgsql;
  */

  @override
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      await supabaseClient
          .from('chat_messages')
          .update({'is_read': true})
          .eq('chat_room_id', chatRoomId)
          .neq('sender_id', userId) // Hanya pesan dari orang lain
          .eq('is_read', false);
    } catch (e) {
      print("Error marking messages as read: $e");
      throw ServerException(
        message: "Failed to mark messages as read: ${e.toString()}",
      );
    }
  }
}
