import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/home/domain/entities/item_preview.dart';
import 'package:olivia/features/home/domain/repositories/home_repository.dart';

class GetRecentFoundItems
    implements UseCase<List<ItemPreviewEntity>, GetRecentItemsParams> {
  final HomeRepository repository;

  GetRecentFoundItems(this.repository);

  @override
  Future<Either<Failure, List<ItemPreviewEntity>>> call(
    GetRecentItemsParams params,
  ) async {
    return await repository.getRecentFoundItems(params.limit);
  }
}

class GetRecentItemsParams extends Equatable {
  final int limit;

  const GetRecentItemsParams({required this.limit});

  @override
  List<Object> get props => [limit];
}
