import 'package:olivia/core/errors/exceptions.dart'; // Ganti 'olivia' dengan nama proyek Anda
import 'package:olivia/features/chat/data/models/chat_room_model.dart'; // Ganti 'olivia'
import 'package:olivia/features/chat/data/models/message_model.dart'; // Ganti 'olivia'
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
  Future<List<MessageModel>> getInitialMessages(String chatRoomId, int limit);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid;

  ChatRemoteDataSourceImpl({required this.supabaseClient})
      : uuid = const Uuid();

  @override
  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    try {
      final stream = supabaseClient
          .rpc(
            'get_user_chat_rooms_with_details',
            params: {'p_user_id': userId},
          )
          .asStream()
          .asyncMap((response) async {
            if (response is List) {
              final List<ChatRoomModel> rooms = response
                  .map(
                    (roomData) => ChatRoomModel.fromJson(
                      roomData as Map<String, dynamic>,
                      userId,
                    ),
                  )
                  .toList();
              rooms.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
              return rooms;
            }
            return <ChatRoomModel>[];
          }).handleError((error) {
            print("Error in getChatRooms stream from RPC: $error");
            return <ChatRoomModel>[];
          });
        return stream;
    } catch (e) {
      print("Error setting up getChatRooms stream: $e");
      // Menggunakan ServerException sesuai definisi Anda
      return Stream.error(ServerException(
        message: "Failed to set up chat rooms stream: ${e.toString()}",
      ));
    }
  }


  @override
  Stream<List<MessageModel>> getMessages(
    String chatRoomId, {
    DateTime? olderThan,
  }) {
    try {
      var query = supabaseClient
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .eq('chat_room_id', chatRoomId)
          .order('sent_at', ascending: true);

      return query.map((listOfMaps) {
        return listOfMaps
            .map((msgJson) => MessageModel.fromJson(msgJson, chatRoomId))
            .toList();
      }).handleError((error){
         print("Error in getMessages stream: $error");
         return <MessageModel>[];
      });
    } catch (e) {
      print("Error setting up getMessages stream: $e");
      return Stream.error(ServerException( // Menggunakan ServerException sesuai definisi Anda
        message: "Failed to set up messages stream: ${e.toString()}",
      ));
    }
  }

  @override
  Future<List<MessageModel>> getInitialMessages(
    String chatRoomId,
    int limit,
  ) async {
    try {
      final response = await supabaseClient
          .from('chat_messages')
          .select()
          .eq('chat_room_id', chatRoomId)
          .order('sent_at', ascending: false)
          .limit(limit);

      return response
          .map((e) => MessageModel.fromJson(e, chatRoomId))
          .toList()
          .reversed
          .toList();
    } on PostgrestException catch (e) {
       // Menggunakan ServerException sesuai definisi Anda, tanpa statusCode
       throw ServerException(message: 'Failed to fetch initial messages: ${e.message}');
    } catch (e) {
      // Menggunakan ServerException sesuai definisi Anda
      throw ServerException(message: "Error fetching initial messages: ${e.toString()}");
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
    String? itemId,
  }) async {
    try {
      final messageData = {
        'id': uuid.v4(),
        'chat_room_id': chatRoomId,
        'sender_id': senderId,
        'content': content,
        'sent_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };
      final response =
          await supabaseClient
              .from('chat_messages')
              .insert(messageData)
              .select()
              .single();

      await supabaseClient
          .from('chat_rooms')
          .update({'last_message_at': messageData['sent_at']})
          .eq('id', chatRoomId);

      return MessageModel.fromJson(response, chatRoomId);
    } on PostgrestException catch (e) {
      // Menggunakan ServerException sesuai definisi Anda, tanpa statusCode
      throw ServerException(message: 'Failed to send message: ${e.message}');
    } catch (e) {
      print("Error sending message: $e");
      // Menggunakan ServerException sesuai definisi Anda
      throw ServerException(message: "Failed to send message: ${e.toString()}");
    }
  }

  Future<String> _executeCreateOrGetChatRoomRpc({
    required String currentUserId,
    required String otherUserId,
    String? itemId,
  }) async {
    try {
      final dynamic rpcResponse = await supabaseClient.rpc(
        'create_or_get_chat_room',
        params: {
          'p_user1_id': currentUserId,
          'p_user2_id': otherUserId,
          'p_item_id': itemId,
        },
      );

      if (rpcResponse != null && rpcResponse is String) {
        return rpcResponse;
      } else {
        // Menggunakan ServerException sesuai definisi Anda
        throw ServerException(
            message:
                'Invalid or null response type from create_or_get_chat_room RPC. Expected String (UUID). Received: ${rpcResponse?.runtimeType}');
      }
    } on PostgrestException catch (e) {
      // Menggunakan ServerException sesuai definisi Anda, tanpa statusCode
      throw ServerException(
          message: 'RPC Error (create_or_get_chat_room): ${e.message}');
    } catch (e) {
      // Menggunakan ServerException sesuai definisi Anda
      throw ServerException(
          message: "Failed to execute create_or_get_chat_room RPC: ${e.toString()}");
    }
  }

  Future<ChatRoomModel> _fetchChatRoomDetailsById(String chatRoomId, String currentUserId) async {
    try {
      final response = await supabaseClient
          .from('chat_rooms')
          .select('''
              id, 
              item_id, 
              created_at, 
              last_message_at,
              chat_participants!inner (
                user_id,
                profiles!inner (id, full_name, avatar_url, email, role, nim, major)
              ),
              chat_messages (
                id,
                sender_id,
                content,
                sent_at,
                is_read
              )
          ''')
          .eq('id', chatRoomId)
          .single();

      return ChatRoomModel.fromJson(response, currentUserId);

    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') { // Kode standar PostgREST untuk "No rows found"
        // Menggunakan ServerException dengan pesan spesifik karena NotFoundException belum Anda definisikan
        throw ServerException(message: 'Chat room with ID $chatRoomId not found.');
      }
      // Menggunakan ServerException sesuai definisi Anda, tanpa statusCode
      throw ServerException(
          message: 'Failed to fetch chat room details: ${e.message}');
    } catch (e) {
      // Menggunakan ServerException sesuai definisi Anda
      throw ServerException(
          message: "Error fetching chat room details for ID $chatRoomId: ${e.toString()}");
    }
  }

  @override
  Future<ChatRoomModel> createOrGetChatRoom({
    required String currentUserId,
    required String otherUserId,
    String? itemId,
  }) async {
    try {
      final String chatRoomId = await _executeCreateOrGetChatRoomRpc(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        itemId: itemId,
      );

      final ChatRoomModel chatRoom = await _fetchChatRoomDetailsById(chatRoomId, currentUserId);
      
      return chatRoom;

    } catch (e) {
      print("Error in createOrGetChatRoom (public method): $e");
      // Cek jika e adalah salah satu dari exception yang sudah Anda definisikan
      // Karena NotFoundException tidak ada, kita hanya cek ServerException
      if (e is ServerException) {
        rethrow;
      }
      // Jika error lain, bungkus sebagai ServerException
      throw ServerException(
        message: "Failed to create or get chat room (overall): ${e.toString()}",
      );
    }
  }
  
  @override
  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      await supabaseClient
          .from('chat_messages')
          .update({'is_read': true})
          .eq('chat_room_id', chatRoomId)
          .neq('sender_id', userId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      // Menggunakan ServerException sesuai definisi Anda, tanpa statusCode
      throw ServerException(message: 'Failed to mark messages as read: ${e.message}');
    } catch (e) {
      print("Error marking messages as read: $e");
      // Menggunakan ServerException sesuai definisi Anda
      throw ServerException(
        message: "Failed to mark messages as read: ${e.toString()}",
      );
    }
  }
}