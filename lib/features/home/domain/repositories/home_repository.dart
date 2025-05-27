import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/item_preview.dart';
import 'package:olivia/features/home/domain/entities/location.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, List<LocationEntity>>> getLocations();
  Future<Either<Failure, List<ItemPreviewEntity>>> getRecentFoundItems(
    int limit,
  );
  Future<Either<Failure, List<ItemPreviewEntity>>> getRecentLostItems(
    int limit,
  );
}
