import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/notification/domain/repositories/notification_repository.dart';

class MarkNotificationAsRead implements UseCase<void, MarkNotificationAsReadParams> {
  final NotificationRepository repository;

  MarkNotificationAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkNotificationAsReadParams params) async {
    if (params.notificationId.isEmpty) {
      return Left(InputValidationFailure("Notification ID tidak valid."));
    }
    return await repository.markNotificationAsRead(params.notificationId);
  }
}

class MarkNotificationAsReadParams extends Equatable {
  final String notificationId;

  const MarkNotificationAsReadParams({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}