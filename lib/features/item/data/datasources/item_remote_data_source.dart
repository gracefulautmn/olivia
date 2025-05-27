import 'dart:io';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/core/utils/constants.dart';
import 'package:olivia/core/utils/enums.dart';
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
          .from('item_images') // Nama bucket Anda
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      // Dapatkan URL publik setelah upload
      final publicUrl = supabaseClient.storage
          .from('item_images')
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
    int? limit = 20, // Default limit
    int? offset = 0, // Default offset for pagination
  }) async {
    try {
      var request = supabaseClient
          .from('items')
          .select(
            '*, categories(*), locations(*), profiles!inner(full_name, avatar_url)',
          ) // Ambil sedikit info reporter
          .order('reported_at', ascending: false);

      if (query != null && query.isNotEmpty) {
        // Menggunakan textSearch atau ilike. textSearch lebih baik jika sudah setup FTS.
        // request = request.textSearch('item_name', query); // Jika kolom di-index untuk FTS
        request = request.or(
          'item_name.ilike.%$query%,description.ilike.%$query%',
        );
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        request = request.eq('category_id', categoryId);
      }
      if (locationId != null && locationId.isNotEmpty) {
        request = request.eq('location_id', locationId);
      }
      if (reportType != null && reportType.isNotEmpty) {
        request = request.eq('report_type', reportType);
      }
      if (status != null && status.isNotEmpty) {
        request = request.eq('status', status);
      } else {
        // Default hanya tampilkan yang 'hilang' atau 'ditemukan_tersedia' jika status tidak dispesifikkan
        request = request.filter(
          'status',
          'in',
          '(${AppConstants.itemStatusLost},${AppConstants.itemStatusFoundAvailable})',
        );
      }

      if (limit != null) {
        request = request.limit(limit);
      }
      if (offset != null && offset > 0) {
        request = request.range(offset, offset + limit! - 1);
      }

      final response = await request;

      return response.map((itemJson) => ItemModel.fromJson(itemJson)).toList();
    } catch (e) {
      print("Error searching items: $e");
      throw ServerException(message: "Gagal mencari barang: ${e.toString()}");
    }
  }

  @override
  Future<ItemModel> claimItemViaQr({
    required String qrCodeData, // Ini adalah item_id
    required String claimerId,
  }) async {
    try {
      // 1. Dapatkan item berdasarkan qr_code_data (yang seharusnya adalah item_id)
      final itemResponse =
          await supabaseClient
              .from('items')
              .select(
                '*, profiles!inner(*)',
              ) // Perlu reporter_id untuk tabel claims
              .eq('qr_code_data', qrCodeData)
              .eq(
                'status',
                AppConstants.itemStatusFoundAvailable,
              ) // Hanya bisa klaim yang tersedia
              .single();

      final itemToClaim = ItemModel.fromJson(itemResponse);

      // 2. Buat entri di tabel claims
      final claimData = {
        'item_id': itemToClaim.id,
        'claimer_id': claimerId,
        'reported_by_id':
            itemToClaim.reporterId, // Diambil dari item yang ditemukan
      };
      await supabaseClient.from('claims').insert(claimData);

      // 3. Update status item menjadi 'ditemukan_diklaim'
      final updatedItemResponse =
          await supabaseClient
              .from('items')
              .update({'status': AppConstants.itemStatusFoundClaimed})
              .eq('id', itemToClaim.id)
              .select('*, profiles!inner(*), categories(*), locations(*)')
              .single();

      return ItemModel.fromJson(updatedItemResponse);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Not found
        throw ServerException(
          message: "Barang tidak ditemukan atau sudah diklaim.",
        );
      }
      if (e.code == '23505' &&
          e.details != null &&
          e.details!.contains('unique_claim_per_item')) {
        // Unique constraint violation
        throw ServerException(message: "Barang ini sudah pernah diklaim.");
      }
      print("Supabase error claiming item: ${e.message}");
      throw ServerException(message: "Gagal mengklaim barang: ${e.message}");
    } catch (e) {
      print("General error claiming item: $e");
      throw ServerException(
        message: "Terjadi kesalahan saat mengklaim barang: ${e.toString()}",
      );
    }
  }

  @override
  Future<List<ItemModel>> getClaimedItemsHistory({
    required String userId,
    bool asClaimer =
        true, // true: barang yg dia klaim, false: barang yg dia temukan dan diklaim orang
  }) async {
    try {
      // Query untuk mendapatkan item_id dari tabel claims
      var claimsQuery = supabaseClient.from('claims').select('item_id');

      if (asClaimer) {
        claimsQuery = claimsQuery.eq('claimer_id', userId);
      } else {
        claimsQuery = claimsQuery.eq('reported_by_id', userId);
      }

      final claimResults = await claimsQuery;
      final List<String> itemIds =
          claimResults.map((claim) => claim['item_id'] as String).toList();

      if (itemIds.isEmpty) {
        return []; // Tidak ada item yang relevan
      }

      // Query untuk mendapatkan detail item berdasarkan item_id yang didapat
      // Juga join dengan tabel claims untuk mendapatkan info siapa yg klaim/lapor dan kapan
      final itemsResponse = await supabaseClient
          .from('items')
          .select(
            '*, categories(*), locations(*), profiles!reporter_id(*), claims!inner(claimer_id, reported_by_id, claimed_at, profiles!claimer_id(full_name, avatar_url), profiles!reported_by_id(full_name, avatar_url))',
          )
          .in_('id', itemIds)
          .eq(
            'status',
            AppConstants.itemStatusFoundClaimed,
          ) // Hanya yang sudah diklaim
          .order(
            'claims(claimed_at)',
            ascending: false,
          ); // Urutkan berdasarkan tanggal klaim terbaru

      return itemsResponse.map((itemJson) {
        // Perlu sedikit penyesuaian untuk memasukkan info dari 'claims' ke dalam ItemModel jika perlu
        // atau buat model khusus untuk History Item. Untuk sekarang, ItemModel akan coba memuatnya jika ada.
        return ItemModel.fromJson(itemJson);
      }).toList();
    } catch (e) {
      print("Error fetching claimed items history: $e");
      throw ServerException(
        message: "Gagal mengambil riwayat barang: ${e.toString()}",
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
      //     await supabaseClient.storage.from('item_images').remove([imagePath]);
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
