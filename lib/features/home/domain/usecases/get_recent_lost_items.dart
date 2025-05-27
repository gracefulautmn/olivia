import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/home/domain/entities/item_preview.dart';
import 'package:olivia/features/home/domain/repositories/home_repository.dart';
import 'package:olivia/features/home/domain/usecases/get_recent_found_items.dart'; // Bisa pakai params yang sama

class GetRecentLostItems
    implements UseCase<List<ItemPreviewEntity>, GetRecentItemsParams> {
  final HomeRepository repository;

  GetRecentLostItems(this.repository);

  @override
  Future<Either<Failure, List<ItemPreviewEntity>>> call(
    GetRecentItemsParams params,
  ) async {
    return await repository.getRecentLostItems(params.limit);
  }
}
