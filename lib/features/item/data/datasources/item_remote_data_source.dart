import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/utils/constants.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/history/data/models/claim_history_entry_model.dart';
import 'package:olivia/features/item/data/models/item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; // Untuk generate UUID jika perlu

abstract class ItemRemoteDataSource {
  Future<ItemModel> reportItem({
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

  Future<ItemModel> getItemDetails(String itemId);

  Future<List<ItemModel>> searchItems({
    String? query,
    String? categoryId,
    String? locationId,
    String? reportType,
    String? status,
    int? limit,
    int? offset,
  });

  Future<ItemModel> claimItemViaQr({
    required String qrCodeData,
    required String claimerId,
  });

  Future<List<ItemModel>> getClaimedItemsHistory({
    required String userId,
    bool asClaimer = true,
  });

  Future<ItemModel> updateItemStatus({
    required String itemId,
    required String newStatus,
    String? claimerId,
  });
  Future<List<ClaimHistoryEntryModel>> getGlobalClaimHistory();
  Future<ItemModel> updateItem(ItemModel item, {File? newImageFile});
  Future<void> deleteItem(String itemId);
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid
  uuid; // Untuk generate ID unik jika perlu client-side (misal untuk QR)

  ItemRemoteDataSourceImpl({required this.supabaseClient})
    : uuid = const Uuid();

  Future<String?> _uploadImage(File imageFile, String itemId) async {
    try {
      final fileName =
          '${itemId}_${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
      final path = await supabaseClient.storage
          .from('item-images') // Nama bucket Anda
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      // Dapatkan URL publik setelah upload
      final publicUrl = supabaseClient.storage
          .from('item-images')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print("Error uploading image: $e");
      // Jangan throw exception di sini agar proses report item tetap lanjut walau gambar gagal
      // Cukup return null dan biarkan user tahu gambar gagal diupload.
      // Atau bisa juga throw jika upload gambar adalah mandatory.
      return null;
    }
  }

  @override
  Future<ItemModel> reportItem({
    required String reporterId,
    required String itemName,
    String? description,
    String? categoryId,
    String? locationId,
    required String reportType, // 'kehilangan' atau 'penemuan'
    File? imageFile,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final itemId = uuid.v4(); // Generate item ID di client
      String? imageUrl;
      String? qrData;

      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, itemId);
      }

      if (reportType == AppConstants.reportTypeFound) {
        // Untuk item penemuan, status awal adalah 'ditemukan_tersedia'
        // dan generate QR code data (bisa berupa item_id itu sendiri)
        qrData = itemId; // Atau format lain: "lostfoundapp://item/$itemId"
      }

      final itemData = {
        'id':
            itemId, // Kita set ID dari client agar bisa digunakan untuk QR dan nama file gambar
        'reporter_id': reporterId,
        'item_name': itemName,
        'description': description,
        'category_id': categoryId,
        'location_id': locationId,
        'report_type': reportType,
        'status':
            reportType == AppConstants.reportTypeFound
                ? AppConstants.itemStatusFoundAvailable
                : AppConstants.itemStatusLost,
        'image_url': imageUrl,
        'qr_code_data': qrData,
        'latitude': latitude,
        'longitude': longitude,
        // 'reported_at' dan 'updated_at' akan di-set oleh default value di DB
      };

      final response =
          await supabaseClient
              .from('items')
              .insert(itemData)
              .select(
                '*, profiles!inner(*), categories(*), locations(*)',
              ) // Ambil data lengkap setelah insert
              .single();

      return ItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      print("Supabase error reporting item: ${e.message}");
      throw ServerException(message: "Gagal melaporkan barang: ${e.message}");
    } catch (e) {
      print("General error reporting item: $e");
      throw ServerException(
        message: "Terjadi kesalahan saat melaporkan barang: ${e.toString()}",
      );
    }
  }

  @override
  Future<ItemModel> getItemDetails(String itemId) async {
    try {
      final response =
          await supabaseClient
              .from('items')
              .select(
                '*, profiles!inner(*), categories(*), locations(*)',
              ) // Ambil data reporter, kategori, lokasi
              .eq('id', itemId)
              .single();
      return ItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Not found
        throw ServerException(message: "Barang tidak ditemukan.");
      }
      print("Supabase error getting item details: ${e.message}");
      throw ServerException(
        message: "Gagal mengambil detail barang: ${e.message}",
      );
    } catch (e) {
      print("General error getting item details: $e");
      throw ServerException(message: "Terjadi kesalahan: ${e.toString()}");
    }
  }

@override
Future<List<ItemModel>> searchItems({
  String? query,
  String? categoryId,
  String? locationId,
  String? reportType,
  String? status,
  int? limit = 20,
  int? offset = 0,
}) async {
  try {
    final int currentLimit = limit ?? 20;
    final int currentOffset = offset ?? 0;

    // Start with select to get PostgrestFilterBuilder
    var queryBuilder = supabaseClient
        .from('items')
        .select('*, categories(*), locations(*), profiles!inner(id, full_name, avatar_url)');

    // Apply filters - now we have PostgrestFilterBuilder which has filter methods
    if (reportType != null && reportType.isNotEmpty) {
      queryBuilder = queryBuilder.eq('report_type', reportType);
    }

    if (status != null && status.isNotEmpty) {
      queryBuilder = queryBuilder.eq('status', status);
    } else if (reportType == null || reportType.isEmpty) {
      // Default status filter if no specific report type or status
      queryBuilder = queryBuilder.inFilter('status', [
        AppConstants.itemStatusLost,
        AppConstants.itemStatusFoundAvailable,
      ]);
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      queryBuilder = queryBuilder.eq('category_id', categoryId);
    }

    if (locationId != null && locationId.isNotEmpty) {
      queryBuilder = queryBuilder.eq('location_id', locationId);
    }

    // Text search on item name and description
    if (query != null && query.isNotEmpty) {
      queryBuilder = queryBuilder.or('item_name.ilike.%$query%,description.ilike.%$query%');
    }

    // Apply ordering and pagination
    final List<Map<String, dynamic>> response = await queryBuilder
        .order('reported_at', ascending: false)
        .range(currentOffset, currentOffset + currentLimit - 1);

    return response
        .map((itemJson) => ItemModel.fromJson(itemJson))
        .toList();

  } catch (e) {
    if (e is PostgrestException) {
      print("Postgrest error searching items: ${e.message}, Code: ${e.code}");
      throw ServerException(message: "Gagal mencari barang (DB Error): ${e.message}");
    }
    if (e is ServerException) rethrow;
    print("General error searching items: $e");
    throw ServerException(message: "Gagal mencari barang: ${e.toString()}");
  }
}

@override
  Future<List<ClaimHistoryEntryModel>> getGlobalClaimHistory() async {
    try {
      final response = await supabaseClient.from('claims').select('''
        claimed_at,
        item:items!inner (*, categories(*), locations(*)),
        claimer:profiles!claims_claimer_id_fkey!inner (*),
        security_reporter:profiles!claims_reported_by_id_fkey!inner (*)
      ''').order('claimed_at', ascending: false);

      return (response as List)
          .map((json) => ClaimHistoryEntryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: "Gagal mengambil riwayat: ${e.message}");
    } catch (e) {
      print("Error getting global claimed items history: $e");
      throw ServerException(message: "Gagal mengambil riwayat klaim global: ${e.toString()}");
    }
  }

@override
Future<ItemModel> claimItemViaQr({
  required String qrCodeData, // QR = item_id
  required String claimerId,
}) async {
  try {
    // Step 1: Cari item berdasarkan QR code (item ID)
    final itemResponse = await supabaseClient
        .from('items')
        .select('*, profiles!inner(*), categories(*), locations(*)')
        .eq('qr_code_data', qrCodeData)
        .eq('status', AppConstants.itemStatusFoundAvailable) // Hanya yang tersedia
        .single();

    final item = ItemModel.fromJson(itemResponse);

    // Step 2: Masukkan klaim ke tabel 'claims'
    final claimData = {
      'item_id': item.id,
      'claimer_id': claimerId,
      'reported_by_id': item.reporterId,
    };

    await supabaseClient.from('claims').insert(claimData);

    // Step 3: Update status item
    final updatedItemResponse = await supabaseClient
        .from('items')
        .update({'status': AppConstants.itemStatusFoundClaimed})
        .eq('id', item.id)
        .select('*, profiles!inner(*), categories(*), locations(*)')
        .single();

    return ItemModel.fromJson(updatedItemResponse);
  } on PostgrestException catch (e) {
    if (e.code == 'PGRST116') {
      throw ServerException(message: "Barang tidak ditemukan atau sudah diklaim.");
    }
    if (e.code == '23505' && e.message.contains('unique_claim_per_item')) {
      throw ServerException(message: "Barang ini sudah pernah diklaim.");
    }
    throw ServerException(message: "Gagal mengklaim barang: ${e.message}");
  } catch (e) {
    throw ServerException(message: "Terjadi kesalahan saat klaim: ${e.toString()}");
  }
}


    @override
  Future<List<ItemModel>> getClaimedItemsHistory({
    required String userId,
    bool asClaimer = true,
  }) async {
    try {
      final column = asClaimer ? 'claimer_id' : 'reported_by_id';
      final response = await supabaseClient
          .from('claims')
          .select('items(*, profiles!inner(*), categories(*), locations(*))')
          .eq(column, userId);

      final items = (response as List)
          .map((e) => ItemModel.fromJson(e['items']))
          .toList();
      return items;
    } catch (e) {
      print("Error getting claimed items history: $e");
      throw ServerException(
        message: "Gagal mengambil riwayat klaim: ${e.toString()}",
      );
    }
  }


  @override
  Future<ItemModel> updateItemStatus({
    required String itemId,
    required String newStatus,
    String?
    claimerId, // Tidak digunakan langsung di sini, tapi berguna di repository
  }) async {
    try {
      final response =
          await supabaseClient
              .from('items')
              .update({'status': newStatus})
              .eq('id', itemId)
              .select('*, profiles!inner(*), categories(*), locations(*)')
              .single();
      return ItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      print("Supabase error updating item status: ${e.message}");
      throw ServerException(
        message: "Gagal memperbarui status barang: ${e.message}",
      );
    } catch (e) {
      print("General error updating item status: $e");
      throw ServerException(message: "Terjadi kesalahan: ${e.toString()}");
    }
  }

  @override
  Future<ItemModel> updateItem(ItemModel item, {File? newImageFile}) async {
    try {
      Map<String, dynamic> dataToUpdate = {
        'item_name': item.itemName,
        'description': item.description,
        'category_id': item.categoryId,
        'location_id': item.locationId,
        // status dan report_type biasanya tidak diubah di sini
      };

      if (newImageFile != null) {
        final newImageUrl = await _uploadImage(newImageFile, item.id);
        if (newImageUrl != null) {
          dataToUpdate['image_url'] = newImageUrl;
          // Hapus gambar lama jika ada dan berhasil upload baru (opsional, butuh logika tambahan)
        }
      }

      final response =
          await supabaseClient
              .from('items')
              .update(dataToUpdate)
              .eq('id', item.id)
              .select('*, profiles!inner(*), categories(*), locations(*)')
              .single();
      return ItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      print("Supabase error updating item: ${e.message}");
      throw ServerException(message: "Gagal memperbarui barang: ${e.message}");
    } catch (e) {
      print("General error updating item: $e");
      throw ServerException(message: "Terjadi kesalahan: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      // Hapus gambar dari storage (opsional, tapi best practice)
      // Ini butuh query dulu untuk get image_url, lalu parse pathnya
      // final itemToDelete = await getItemDetails(itemId); // Untuk mendapatkan image_url
      // if (itemToDelete.imageUrl != null && itemToDelete.imageUrl!.isNotEmpty) {
      //   try {
      //     final imagePath = Uri.parse(itemToDelete.imageUrl!).pathSegments.last;
      //     await supabaseClient.storage.from('item-images').remove([imagePath]);
      //   } catch (storageError) {
      //     print("Error deleting image from storage: $storageError");
      //     // Lanjutkan proses hapus item dari DB meskipun gambar gagal dihapus
      //   }
      // }

      await supabaseClient.from('items').delete().eq('id', itemId);
    } on PostgrestException catch (e) {
      print("Supabase error deleting item: ${e.message}");
      throw ServerException(message: "Gagal menghapus barang: ${e.message}");
    } catch (e) {
      print("General error deleting item: $e");
      throw ServerException(message: "Terjadi kesalahan: ${e.toString()}");
    }
  }
}
