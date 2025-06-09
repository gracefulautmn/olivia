import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';

// Asumsi Anda sudah mendaftarkan use case ini di service_locator
class DeleteItem implements UseCase<void, DeleteItemParams> {
  final ItemRepository repository;

  DeleteItem(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteItemParams params) async {
    return await repository.deleteItem(params.itemId);
  }
}

class DeleteItemParams extends Equatable {
  final String itemId;

  const DeleteItemParams({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}
