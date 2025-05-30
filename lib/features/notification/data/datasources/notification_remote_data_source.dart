import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/features/notification/data/models/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    int limit = 20,
    int offset = 0,
  });
  Stream<NotificationModel?> getNewNotificationStream(String userId);
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> markAllNotificationsAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Future<int> getUnreadNotificationCount(String userId);
  Stream<int> getUnreadNotificationCountStream(String userId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabaseClient;

  NotificationRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await supabaseClient
          .from('notifications')
          .select()
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);
      
      return response
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print("Error fetching notifications: $e");
      throw ServerException(message: "Failed to fetch notifications: ${e.toString()}");
    }
  }

  @override
  Stream<NotificationModel?> getNewNotificationStream(String userId) {
    try {
      return supabaseClient
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .map((listOfNotifications) {
            if (listOfNotifications.isNotEmpty) {
              // Asumsi notifikasi terbaru adalah yang pertama setelah order by created_at desc
              // Namun, stream mungkin tidak selalu mengembalikan semua data terurut jika ada update parsial.
              // Ini adalah simplifikasi. Idealnya, server mengirim event spesifik untuk notif baru.
              final latestNotificationData = listOfNotifications.firstWhere(
                (n) => n['recipient_id'] == userId, // Pastikan lagi ini untuk user yang benar
                orElse: () => <String,dynamic>{} // Kembalikan map kosong jika tidak ada yg match
              );
              if (latestNotificationData.isNotEmpty) {
                 // Cek apakah notifikasi ini benar-benar 'baru' (belum pernah diproses oleh BLoC)
                 // bisa dilakukan dengan membandingkan `created_at` atau `id` dengan yang sudah ada di BLoC.
                 // Untuk sekarang, kita anggap ini adalah notifikasi yang relevan untuk diproses.
                return NotificationModel.fromJson(latestNotificationData);
              }
            }
            return null;
          }).handleError((error){
             print("Error in notification stream: $error");
             return null;
          });
    } catch (e) {
      print("Error setting up new notification stream: $e");
      throw ServerException(message: "Failed to setup new notification stream: ${e.toString()}");
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print("Error marking notification as read: $e");
      throw ServerException(message: "Failed to mark notification as read: ${e.toString()}");
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
     try {
      await supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print("Error marking all notifications as read: $e");
      throw ServerException(message: "Failed to mark all notifications as read: ${e.toString()}");
    }
  }
  
  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      print("Error deleting notification: $e");
      throw ServerException(message: "Failed to delete notification: ${e.toString()}");
    }
  }

  @override
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      // PERBAIKAN DI SINI:
      // Menggunakan .count() sebagai method terpisah setelah filter.
      final response = await supabaseClient
          .from('notifications')
          .select('id') // Select minimal satu kolom, tidak harus 'id'
          .eq('recipient_id', userId)
          .eq('is_read', false)
          .count(CountOption.exact); // Panggil count() di sini
          
      return response.count ?? 0; // Extract the count value or return 0 if null
    } catch (e) {
      print("Error getting unread notification count: $e");
      throw ServerException(message: "Failed to get unread count: ${e.toString()}");
    }
  } 

  @override
  Stream<int> getUnreadNotificationCountStream(String userId) {
    try {
      // PERBAIKAN DI SINI JUGA UNTUK STREAM COUNT (Meskipun ini tetap pendekatan client-side counting)
      // Supabase Realtime tidak secara langsung memberikan stream untuk hasil agregasi seperti count.
      // Cara yang paling umum adalah memantau perubahan pada tabel yang relevan dan menghitung ulang di client.
      // Atau menggunakan database functions/triggers untuk mengelola tabel count terpisah.
      
      // Ini adalah pendekatan client-side counting dari stream data.
      return supabaseClient
          .from('notifications')
          .stream(primaryKey: ['id']) // Pantau semua perubahan di tabel
          .eq('recipient_id', userId) // Filter untuk user ini
          .map((listOfNotifications) {
            // Hitung manual dari snapshot notifikasi yang belum dibaca
            return listOfNotifications.where((n) => n['is_read'] == false).length;
          }).handleError((error){
             print("Error in unread notification count stream: $error");
             return 0; // Kembalikan 0 jika ada error di stream
          });
    } catch (e) {
       print("Error setting up unread notification count stream: $e");
      throw ServerException(message: "Failed to setup unread count stream: ${e.toString()}");
    }
  }
}