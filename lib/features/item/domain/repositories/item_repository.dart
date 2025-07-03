import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/history/domain/entities/claim_history_entry.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
// Impor params dari use case, asumsikan path ini benar atau params dipindahkan ke lokasi yang dapat diakses
import 'package:olivia/features/item/domain/usecases/submit_guest_claim.dart';

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
    String? reporterId,
    String? status,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, ItemEntity>> claimItemViaQr({
    required String qrCodeData,
    required String claimerId,
  });

  // === METODE BARU UNTUK KLAIM OLEH TAMU ===
  Future<Either<Failure, void>> submitGuestClaim(SubmitGuestClaimParams params);

  Future<Either<Failure, List<ClaimHistoryEntry>>> getGlobalClaimHistory();

  Future<Either<Failure, ItemEntity>> updateItem(ItemEntity item, {File? newImageFile});

  Future<Either<Failure, void>> deleteItem(String itemId);
}
