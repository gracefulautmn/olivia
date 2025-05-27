import 'dart:io'; // Untuk File gambar
import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/item/domain/entities/item.dart';

abstract class ItemRepository {
  Future<Either<Failure, ItemEntity>> reportItem({
    required String reporterId,
    required String itemName,
    String? description,
    String? categoryId,
    String? locationId,
    required String reportType, // 'kehilangan' atau 'penemuan'
    File? imageFile, // File gambar yang akan diupload
    double? latitude,
    double? longitude,
  });

  Future<Either<Failure, ItemEntity>> getItemDetails(String itemId);

  Future<Either<Failure, List<ItemEntity>>> searchItems({
    String? query,
    String? categoryId,
    String? locationId,
    String? reportType, // 'kehilangan', 'penemuan', atau null untuk semua
    String? status, // 'hilang', 'ditemukan_tersedia', atau null
    int? limit,
    int? offset,
  });

  Future<Either<Failure, ItemEntity>> claimItemViaQr({
    required String qrCodeData, // Data dari QR code (item_id)
    required String claimerId,  // User ID yang mengklaim
  });

  Future<Either<Failure, List<ItemEntity>>> getClaimedItemsHistory({
    required String userId, // User ID untuk melihat riwayat klaimnya atau temuannya yg diklaim
    bool asClaimer = true, // true jika melihat barang yg dia klaim, false jika melihat barang yg dia temukan dan sudah diklaim
  });

  Future<Either<Failure, ItemEntity>> updateItemStatus({
    required String itemId,
    required String newStatus, // 'ditemukan_diklaim'
    String? claimerId, // Opsional, jika status berubah karena diklaim
  });

  // Opsional: update dan delete item oleh reporter
  Future<Either<Failure, ItemEntity>> updateItem(ItemEntity item, {File? newImageFile});
  Future<Either<Failure, void>> deleteItem(String itemId);
}