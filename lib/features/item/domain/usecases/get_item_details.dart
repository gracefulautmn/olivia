import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';

class GetItemDetails implements UseCase<ItemEntity, GetItemDetailsParams> {
  final ItemRepository repository;

  GetItemDetails(this.repository);

  @override
  Future<Either<Failure, ItemEntity>> call(GetItemDetailsParams params) async {
    if (params.itemId.isEmpty) {
      return Left(InputValidationFailure("Item ID tidak valid."));
    }
    return await repository.getItemDetails(params.itemId);
  }
}

class GetItemDetailsParams extends Equatable {
  final String itemId;

  const GetItemDetailsParams({required this.itemId});

  @override
  List<Object> get props => [itemId];
}
