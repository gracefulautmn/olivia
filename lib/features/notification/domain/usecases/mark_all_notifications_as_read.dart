import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/notification/domain/repositories/notification_repository.dart';

class MarkAllNotificationsAsRead implements UseCase<void, MarkAllNotificationsAsReadParams> {
  final NotificationRepository repository;

  MarkAllNotificationsAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkAllNotificationsAsReadParams params) async {
    if (params.userId.isEmpty) {
      return Left(AuthFailure("User ID tidak valid."));
    }
    return await repository.markAllNotificationsAsRead(params.userId);
  }
}

class MarkAllNotificationsAsReadParams extends Equatable {
  final String userId;

  const MarkAllNotificationsAsReadParams({required this.userId});

  @override
  List<Object> get props => [userId];
}