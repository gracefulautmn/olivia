import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/notification/domain/repositories/notification_repository.dart';

class GetUnreadNotificationCount implements UseCase<int, GetUnreadNotificationCountParams> {
  final NotificationRepository repository;

  GetUnreadNotificationCount(this.repository);

  @override
  Future<Either<Failure, int>> call(GetUnreadNotificationCountParams params) async {
    if (params.userId.isEmpty) {
      return Left(AuthFailure("User ID tidak valid."));
    }
    return await repository.getUnreadNotificationCount(params.userId);
  }
}

class GetUnreadNotificationCountParams extends Equatable {
  final String userId;
  const GetUnreadNotificationCountParams({required this.userId});
  @override
  List<Object> get props => [userId];
}

// Untuk stream count (jika diperlukan terpisah dari BLoC utama notifikasi)
class GetUnreadNotificationCountStream {
  final NotificationRepository repository;
  GetUnreadNotificationCountStream(this.repository);

  Stream<Either<Failure, int>> call(GetUnreadNotificationCountParams params) {
    if (params.userId.isEmpty) {
      return Stream.value(Left(AuthFailure("User ID tidak valid.")));
    }
    return repository.getUnreadNotificationCountStream(params.userId);
  }
}