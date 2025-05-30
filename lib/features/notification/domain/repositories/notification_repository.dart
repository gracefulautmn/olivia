import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/notification/domain/entities/notification.dart';

abstract class NotificationRepository {
  // Mendapatkan notifikasi untuk user tertentu, dengan pagination
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  // Stream untuk notifikasi baru (opsional, jika ingin real-time)
  Stream<Either<Failure, NotificationEntity>> getNewNotificationStream(String userId);

  Future<Either<Failure, void>> markNotificationAsRead(String notificationId);
  Future<Either<Failure, void>> markAllNotificationsAsRead(String userId);

  // Opsional: Hapus notifikasi
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  // Opsional: Mendapatkan jumlah notifikasi belum dibaca
  Future<Either<Failure, int>> getUnreadNotificationCount(String userId);
  Stream<Either<Failure, int>> getUnreadNotificationCountStream(String userId);
}