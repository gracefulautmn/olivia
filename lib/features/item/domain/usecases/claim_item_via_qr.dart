import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';

class ClaimItemViaQr implements UseCase<ItemEntity, ClaimItemParams> {
  final ItemRepository repository;

  ClaimItemViaQr(this.repository);

  @override
  Future<Either<Failure, ItemEntity>> call(ClaimItemParams params) async {
    if (params.qrCodeData.isEmpty) {
      return Left(InputValidationFailure("Data QR tidak valid."));
    }
    if (params.claimerId.isEmpty) {
      return Left(
        AuthFailure("Pengguna tidak terautentikasi untuk mengklaim."),
      );
    }
    return await repository.claimItemViaQr(
      qrCodeData: params.qrCodeData,
      claimerId: params.claimerId,
    );
  }
}

class ClaimItemParams extends Equatable {
  final String qrCodeData;
  final String claimerId;

  const ClaimItemParams({required this.qrCodeData, required this.claimerId});

  @override
  List<Object> get props => [qrCodeData, claimerId];
}
