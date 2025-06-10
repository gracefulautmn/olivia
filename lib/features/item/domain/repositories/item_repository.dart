import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/history/domain/entities/claim_history_entry.dart';

abstract class ItemRepository {
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
  });

  Future<Either<Failure, ItemEntity>> getItemDetails(String itemId);

  Future<Either<Failure, List<ItemEntity>>> searchItems({
    String? query,
    String? categoryId,
    String? locationId,
    String? reportType,
    String? status,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, ItemEntity>> claimItemViaQr({
    required String qrCodeData,
    required String claimerId,
  });

  // === METODE BARU UNTUK RIWAYAT GLOBAL ===
  Future<Either<Failure, List<ClaimHistoryEntry>>> getGlobalClaimHistory();

  // === METODE LAMA YANG SUDAH TIDAK RELEVAN DIHAPUS ===
  // Future<Either<Failure, List<ItemEntity>>> getClaimedItemsHistory(...) -> Dihapus
  // Future<Either<Failure, ItemEntity>> updateItemStatus(...) -> Dihapus

  // Update dan delete item oleh reporter tetap ada
  Future<Either<Failure, ItemEntity>> updateItem(ItemEntity item, {File? newImageFile});
  Future<Either<Failure, void>> deleteItem(String itemId);
}
