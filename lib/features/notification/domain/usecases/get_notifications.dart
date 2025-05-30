import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/notification/domain/entities/notification.dart';
import 'package:olivia/features/notification/domain/repositories/notification_repository.dart';

class GetNotifications implements UseCase<List<NotificationEntity>, GetNotificationsParams> {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(GetNotificationsParams params) async {
    if (params.userId.isEmpty) {
      return Left(AuthFailure("User ID tidak valid."));
    }
    return await repository.getNotifications(
      userId: params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetNotificationsParams extends Equatable {
  final String userId;
  final int limit;
  final int offset;

  const GetNotificationsParams({
    required this.userId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [userId, limit, offset];
}