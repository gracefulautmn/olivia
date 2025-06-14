import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';

class SearchItems implements UseCase<List<ItemEntity>, SearchItemsParams> {
  final ItemRepository repository;

  SearchItems(this.repository);

  @override
  Future<Either<Failure, List<ItemEntity>>> call(SearchItemsParams params) async {
    return await repository.searchItems(
      query: params.query,
      categoryId: params.categoryId,
      locationId: params.locationId,
      reportType: params.reportType,
      status: params.status,
      reporterId: params.reporterId, // Meneruskan reporterId ke repository
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class SearchItemsParams extends Equatable {
  final String? query;
  final String? categoryId;
  final String? locationId;
  final String? reportType;
  final String? status;
  // PERBAIKAN: Tambahkan parameter reporterId
  final String? reporterId;
  final int? limit;
  final int? offset;

  const SearchItemsParams({
    this.query,
    this.categoryId,
    this.locationId,
    this.reportType,
    this.status,
    this.reporterId, // Tambahkan di konstruktor
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [
        query,
        categoryId,
        locationId,
        reportType,
        status,
        reporterId, // Tambahkan di props
        limit,
        offset,
      ];
}
