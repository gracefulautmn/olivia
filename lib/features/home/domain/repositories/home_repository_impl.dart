import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/home/data/datasources/home_remote_data_source.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/item_preview.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/home/domain/repositories/home_repository.dart';
// import 'package:olivia/core/network/network_info.dart'; // Jika digunakan

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    // if (await networkInfo.isConnected) {
    try {
      final categoryModels = await remoteDataSource.getCategories();
      return Right(categoryModels); // Model adalah subtype dari Entity
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure("Failed to get categories: ${e.toString()}"));
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocations() async {
    // if (await networkInfo.isConnected) {
    try {
      final locationModels = await remoteDataSource.getLocations();
      return Right(locationModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure("Failed to get locations: ${e.toString()}"));
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, List<ItemPreviewEntity>>> getRecentFoundItems(
    int limit,
  ) async {
    // if (await networkInfo.isConnected) {
    try {
      final itemPreviewModels = await remoteDataSource.getRecentFoundItems(
        limit,
      );
      return Right(itemPreviewModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure("Failed to get recent found items: ${e.toString()}"),
      );
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, List<ItemPreviewEntity>>> getRecentLostItems(
    int limit,
  ) async {
    // if (await networkInfo.isConnected) {
    try {
      final itemPreviewModels = await remoteDataSource.getRecentLostItems(
        limit,
      );
      return Right(itemPreviewModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure("Failed to get recent lost items: ${e.toString()}"),
      );
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }
}
