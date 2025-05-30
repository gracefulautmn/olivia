import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/exceptions.dart' as core_exceptions;
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/item/data/datasources/item_remote_data_source.dart';
import 'package:olivia/features/item/data/models/item_model.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';
// import 'package:olivia/core/network/network_info.dart'; // Jika digunakan
import 'package:supabase_flutter/supabase_flutter.dart'; // Untuk akses SupabaseClient jika perlu (misal upload gambar)

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo;
  final SupabaseClient
  supabaseClient; // Untuk upload gambar jika dipisah dari datasource

  ItemRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
    required this.supabaseClient, // DI untuk SupabaseClient
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
    // if (await networkInfo.isConnected) {
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
      return Left(ServerFailure(e.message));
    // ignore: dead_code_on_catch_subtype
    } on core_exceptions.AuthException catch (e) {
      // Jika ada error auth spesifik
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, ItemEntity>> getItemDetails(String itemId) async {
    // if (await networkInfo.isConnected) {
    try {
      final itemModel = await remoteDataSource.getItemDetails(itemId);
      return Right(itemModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
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
    // if (await networkInfo.isConnected) {
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
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, ItemEntity>> claimItemViaQr({
    required String qrCodeData,
    required String claimerId,
  }) async {
    // if (await networkInfo.isConnected) {
    try {
      final itemModel = await remoteDataSource.claimItemViaQr(
        qrCodeData: qrCodeData,
        claimerId: claimerId,
      );
      // Di sini Anda bisa memicu pembuatan notifikasi untuk si penemu (reporter)
      // _sendClaimNotification(itemModel.reporterId, itemModel.itemName, claimerId);
      return Right(itemModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, List<ItemEntity>>> getClaimedItemsHistory({
    required String userId,
    bool asClaimer = true,
  }) async {
    // if (await networkInfo.isConnected) {
    try {
      final itemModels = await remoteDataSource.getClaimedItemsHistory(
        userId: userId,
        asClaimer: asClaimer,
      );
      return Right(itemModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, ItemEntity>> updateItemStatus({
    required String itemId,
    required String newStatus,
    String? claimerId,
  }) async {
    // if (await networkInfo.isConnected) {
    try {
      final itemModel = await remoteDataSource.updateItemStatus(
        itemId: itemId,
        newStatus: newStatus,
        claimerId: claimerId,
      );
      return Right(itemModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, ItemEntity>> updateItem(
    ItemEntity item, {
    File? newImageFile,
  }) async {
    // if (await networkInfo.isConnected) {
    try {
      // Pastikan item adalah ItemModel atau konversi jika perlu
      final itemModel =
          item is ItemModel
              ? item
              : ItemModel(
                id: item.id,
                reporterId: item.reporterId,
                itemName: item.itemName,
                description: item.description,
                categoryId: item.categoryId,
                locationId: item.locationId,
                reportType: item.reportType,
                status: item.status,
                imageUrl: item.imageUrl,
                qrCodeData: item.qrCodeData,
                reportedAt: item.reportedAt,
                updatedAt: item.updatedAt,
                latitude: item.latitude,
                longitude: item.longitude,
              );
      final updatedItemModel = await remoteDataSource.updateItem(
        itemModel,
        newImageFile: newImageFile,
      );
      return Right(updatedItemModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    // if (await networkInfo.isConnected) {
    try {
      await remoteDataSource.deleteItem(itemId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        UnknownFailure("An unexpected error occurred: ${e.toString()}"),
      );
    }
    // } else {
    //   return Left(NetworkFailure("No internet connection"));
    // }
  }
}
