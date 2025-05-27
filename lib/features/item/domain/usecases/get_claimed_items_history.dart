import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';

class GetClaimedItemsHistory
    implements UseCase<List<ItemEntity>, GetClaimedItemsHistoryParams> {
  final ItemRepository repository;

  GetClaimedItemsHistory(this.repository);

  @override
  Future<Either<Failure, List<ItemEntity>>> call(
    GetClaimedItemsHistoryParams params,
  ) async {
    if (params.userId.isEmpty) {
      return Left(AuthFailure("User ID tidak valid untuk melihat riwayat."));
    }
    return await repository.getClaimedItemsHistory(
      userId: params.userId,
      asClaimer: params.asClaimer,
    );
  }
}

class GetClaimedItemsHistoryParams extends Equatable {
  final String userId;
  final bool
  asClaimer; // true: barang yg dia klaim, false: barang yg dia temukan dan diklaim orang

  const GetClaimedItemsHistoryParams({
    required this.userId,
    this.asClaimer = true,
  });

  @override
  List<Object> get props => [userId, asClaimer];
}
