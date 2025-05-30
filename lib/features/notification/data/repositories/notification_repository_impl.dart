import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:olivia/features/notification/domain/entities/notification.dart';
import 'package:olivia/features/notification/domain/repositories/notification_repository.dart';
// import 'package:olivia/core/network/network_info.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    // if (await networkInfo.isConnected) {
      try {
        final notificationModels = await remoteDataSource.getNotifications(
          userId: userId,
          limit: limit,
          offset: offset,
        );
        return Right(notificationModels);
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
  Stream<Either<Failure, NotificationEntity>> getNewNotificationStream(String userId) {
     try {
      return remoteDataSource.getNewNotificationStream(userId).map((notificationModel) {
        if (notificationModel != null) {
          return Right<Failure, NotificationEntity>(notificationModel);
        }
        // Jika null, stream tidak emit apa-apa atau bisa di-filter di BLoC
        // Untuk konsistensi Either, bisa return Left jika null, tapi mungkin tidak ideal untuk stream continue
        // Lebih baik filter null di BLoC atau biarkan stream tidak emit.
        // Asumsi stream hanya emit jika ada data.
        // Jika ingin error jika null:
        // return Left<Failure, NotificationEntity>(ServerFailure("No new notification from stream"));
        // Namun, ini akan menghentikan BLoC dari memproses Right berikutnya.
        // Jadi, kita biarkan BLoC yang handle null.
        // Atau, stream dari datasource harusnya tidak emit null jika tidak ada notif baru.
        // Untuk sekarang, jika datasource emit null, kita tidak emit apa-apa di sini (dengan filter di map)
        // Tapi karena datasource di atas bisa return null, kita harus handle.
        // Kita akan buat stream ini hanya emit Right jika ada data.
        // Perubahan: stream dari datasource tidak akan emit null jika tidak ada notif baru,
        // dia akan menunggu sampai ada. Jadi null check di sini mungkin tidak perlu jika datasource sudah benar.
        // Jika stream datasource *bisa* emit null, maka:
        if (notificationModel == null) {
            // Ini akan membuat stream emit error, mungkin bukan yang diinginkan.
            // return Left<Failure, NotificationEntity>(ServerFailure("Received null notification from stream"));
            // Cara lain adalah tidak emit apa-apa jika null
            throw "Received null, skipping emit"; // Akan ditangkap oleh handleError
        }
        return Right<Failure, NotificationEntity>(notificationModel);
      }).handleError((error) {
        if (error is ServerException) {
          return Left<Failure, NotificationEntity>(ServerFailure(error.message));
        }
        if (error is String && error == "Received null, skipping emit") {
            // Jangan emit error, biarkan stream lanjut
            // Ini adalah cara kasar, lebih baik stream datasource tidak emit null
            // atau BLoC yang filter
            return Left<Failure, NotificationEntity>(UnknownFailure("Skipped null notification")); // Ini akan jadi error
            // Lebih baik:
            // throw error; // agar di-handle oleh BLoC atau StreamController
        }
        return Left<Failure, NotificationEntity>(UnknownFailure("Stream error: ${error.toString()}"));
      }).where((either) => either.isRight()); // Hanya teruskan jika Right
    } catch (e) {
      return Stream.value(Left(ServerFailure("Failed to initialize new notification stream: ${e.toString()}")));
    }
  }


  @override
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId) async {
    // if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markNotificationAsRead(notificationId);
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

  @override
  Future<Either<Failure, void>> markAllNotificationsAsRead(String userId) async {
    // if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markAllNotificationsAsRead(userId);
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

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    // if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteNotification(notificationId);
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

  @override
  Future<Either<Failure, int>> getUnreadNotificationCount(String userId) async {
    // if (await networkInfo.isConnected) {
      try {
        final count = await remoteDataSource.getUnreadNotificationCount(userId);
        return Right(count);
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
  Stream<Either<Failure, int>> getUnreadNotificationCountStream(String userId) {
     try {
      return remoteDataSource.getUnreadNotificationCountStream(userId).map((count) {
        return Right<Failure, int>(count);
      }).handleError((error) {
        if (error is ServerException) {
          return Left<Failure, int>(ServerFailure(error.message));
        }
        return Left<Failure, int>(UnknownFailure("Stream error for unread count: ${error.toString()}"));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure("Failed to initialize unread count stream: ${e.toString()}")));
    }
  }
}