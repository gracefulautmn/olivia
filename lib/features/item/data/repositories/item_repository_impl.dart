import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/errors/failures.dart';
// import 'package:olivia/core/network/network_info.dart'; // Aktifkan jika Anda menggunakan network check
import 'package:olivia/features/history/domain/entities/claim_history_entry.dart';
import 'package:olivia/features/item/data/datasources/item_remote_data_source.dart';
import 'package:olivia/features/item/data/models/item_model.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';

// Asumsi Anda mendaftarkan ini di service_locator
class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo; // Anda bisa mengaktifkan ini kembali jika diperlukan

  ItemRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, ItemEntity>> reportItem({
    required String reporterId,
    required String itemName,
    String? description,
    String? categoryId,
    String? locationId,
    required String reportType,
    File? imageFile,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final itemModel = await remoteDataSource.reportItem(
        reporterId: reporterId,
        itemName: itemName,
        description: description,
        categoryId: categoryId,
        locationId: locationId,
        reportType: reportType,
        imageFile: imageFile,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(itemModel);
    } on ServerException catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(AuthFailure(e.message));
    } catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> getItemDetails(String itemId) async {
    try {
      final itemModel = await remoteDataSource.getItemDetails(itemId);
      return Right(itemModel);
    } on ServerException catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(ServerFailure(e.message));
    } catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> searchItems({
    String? query,
    String? categoryId,
    String? locationId,
    String? reportType,
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final itemModels = await remoteDataSource.searchItems(
        query: query,
        categoryId: categoryId,
        locationId: locationId,
        reportType: reportType,
        status: status,
        limit: limit,
        offset: offset,
      );
      return Right(itemModels);
    } on ServerException catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(ServerFailure(e.message));
    } catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> claimItemViaQr({
    required String qrCodeData,
    required String claimerId,
  }) async {
    try {
      final itemModel = await remoteDataSource.claimItemViaQr(
        qrCodeData: qrCodeData,
        claimerId: claimerId,
      );
      return Right(itemModel);
    } on ServerException catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(ServerFailure(e.message));
    } catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
  }
  
  @override
  Future<Either<Failure, List<ClaimHistoryEntry>>> getGlobalClaimHistory() async {
    try {
      final historyModels = await remoteDataSource.getGlobalClaimHistory();
      return Right(historyModels);
    } on ServerException catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(ServerFailure(e.message));
    } catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(UnknownFailure("Gagal mengambil riwayat global: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, ItemEntity>> updateItem(
    ItemEntity item, {
    File? newImageFile,
  }) async {
    try {
      final itemModel =
          item is ItemModel ? item : ItemModel.fromEntity(item);
      final updatedItemModel = await remoteDataSource.updateItem(
        itemModel,
        newImageFile: newImageFile,
      );
      return Right(updatedItemModel);
    } on ServerException catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(ServerFailure(e.message));
    } catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    try {
      await remoteDataSource.deleteItem(itemId);
      return const Right(null);
    } on ServerException catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(ServerFailure(e.message));
    } catch (e) {
      // PERBAIKAN: Menggunakan parameter posisional
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
  }
}
