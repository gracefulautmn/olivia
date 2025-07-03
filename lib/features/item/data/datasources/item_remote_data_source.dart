import 'dart:io';
import 'package:olivia/core/errors/exceptions.dart';
import 'package:olivia/features/history/data/models/claim_history_entry_model.dart';
import 'package:olivia/features/item/data/models/item_model.dart';
import 'package:olivia/features/item/domain/usecases/submit_guest_claim.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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
    String? reporterId,
    int? limit,
    int? offset,
  });

  Future<ItemModel> claimItemViaQr({
    required String qrCodeData,
    required String claimerId,
  });
  
  Future<void> submitGuestClaim(SubmitGuestClaimParams params);

  Future<List<ClaimHistoryEntryModel>> getGlobalClaimHistory();

  Future<ItemModel> updateItem(ItemModel item, {File? newImageFile});
  Future<void> deleteItem(String itemId);
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final SupabaseClient supabaseClient;
  final Uuid uuid;

  ItemRemoteDataSourceImpl({required this.supabaseClient}) : uuid = const Uuid();

  @override
  Future<ItemModel> getItemDetails(String itemId) async {
     try {
       // --- PERBAIKAN DI SINI ---
       // Query sekarang juga mengambil data dari tabel 'claims' yang berhubungan,
       // termasuk profil pengklaim (claimerProfile) dan detail tamu.
       final response = await supabaseClient
           .from('items')
           .select('''
              *,
              reporterProfile:profiles!items_reporter_id_fkey(*),
              category:categories(*),
              location:locations(*),
              claims (
                claimed_at,
                guest_claimer_details,
                claimerProfile:profiles!claims_claimer_id_fkey(*)
              )
           ''')
           .eq('id', itemId)
           .single();
       return ItemModel.fromJson(response);
     } on PostgrestException catch (e) {
       if (e.code == 'PGRST116') {
         throw ServerException(message: "Barang tidak ditemukan.");
       }
       throw ServerException(message: "Gagal mengambil detail barang: ${e.message}");
     } catch (e) {
       throw ServerException(message: "Terjadi kesalahan: ${e.toString()}");
     }
  }

  // Sisa metode lainnya tetap sama...
  
  Future<String?> _uploadImage(File imageFile, String itemId) async {
    try {
      final fileName = '${itemId}_${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
      await supabaseClient.storage.from('item-images').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      final publicUrl = supabaseClient.storage.from('item-images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      // ignore: avoid_print
      print("Error uploading image: $e");
      return null;
    }
  }

  @override
  Future<List<ClaimHistoryEntryModel>> getGlobalClaimHistory() async {
    try {
      final response = await supabaseClient.from('claims').select('''
        claimed_at,
        guest_claimer_details, 
        item:items!inner (*, categories(*), locations(*), profiles!inner(*)),
        claimer:profiles!claims_claimer_id_fkey!left (*), 
        security_reporter:profiles!claims_reported_by_id_fkey!inner (*)
      ''').order('claimed_at', ascending: false);

      final List<ClaimHistoryEntryModel> validEntries = [];
      for (final jsonEntry in (response as List)) {
        if (jsonEntry != null &&
            jsonEntry['item'] != null &&
            jsonEntry['security_reporter'] != null) {
          try {
            validEntries.add(ClaimHistoryEntryModel.fromJson(jsonEntry as Map<String, dynamic>));
          } catch (e) {
            // ignore: avoid_print
            print('Gagal mem-parsing satu entri riwayat klaim: $e. Data: $jsonEntry');
          }
        } else {
          // ignore: avoid_print
          print('Melewatkan entri riwayat klaim yang tidak valid atau tidak lengkap: $jsonEntry');
        }
      }
      return validEntries;
          
    } on PostgrestException catch (e) {
      throw ServerException(message: "Gagal mengambil riwayat: ${e.message}");
    } catch (e) {
      throw ServerException(message: "Gagal mengambil riwayat klaim global: ${e.toString()}");
    }
  }

  @override
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
  }) async {
    try {
      final itemId = uuid.v4();
      String? imageUrl;
      String? qrData;

      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, itemId);
      }

      if (reportType == "penemuan") {
        qrData = itemId;
      }

      final itemData = {
        'id': itemId,
        'reporter_id': reporterId,
        'item_name': itemName,
        'description': description,
        'category_id': categoryId,
        'location_id': locationId,
        'report_type': reportType,
        'status': reportType == "penemuan" ? "ditemukan_tersedia" : "hilang",
        'image_url': imageUrl,
        'qr_code_data': qrData,
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await supabaseClient
          .from('items')
          .insert(itemData)
          .select('*, reporterProfile:profiles!items_reporter_id_fkey(*), category:categories(*), location:locations(*)')
          .single();

      return ItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: "Gagal melaporkan barang: ${e.message}");
    } catch (e) {
      throw ServerException(
        message: "Terjadi kesalahan saat melaporkan barang: ${e.toString()}",
      );
    }
  }

  @override
  Future<List<ItemModel>> searchItems({
    String? query,
    String? categoryId,
    String? locationId,
    String? reportType,
    String? status,
    String? reporterId,
    int? limit = 20,
    int? offset = 0,
  }) async {
    try {
      var queryBuilder = supabaseClient
          .from('items')
          .select('*, category:categories(*), location:locations(*), reporterProfile:profiles!items_reporter_id_fkey(*)');

      if (reporterId != null && reporterId.isNotEmpty) {
        queryBuilder = queryBuilder.eq('reporter_id', reporterId);
      }
      
      if (reportType != null && reportType.isNotEmpty) {
        queryBuilder = queryBuilder.eq('report_type', reportType);
      }

      if (status != null && status.isNotEmpty) {
        queryBuilder = queryBuilder.eq('status', status);
      } else {
        if (reporterId == null || reporterId.isEmpty) {
           queryBuilder = queryBuilder.inFilter('status', [
             'hilang',
             'ditemukan_tersedia',
           ]);
        }
      }
      
      if (categoryId != null && categoryId.isNotEmpty) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }
      if (locationId != null && locationId.isNotEmpty) {
        queryBuilder = queryBuilder.eq('location_id', locationId);
      }
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder
            .or('item_name.ilike.%$query%,description.ilike.%$query%');
      }
      
      final response = await queryBuilder
          .order('reported_at', ascending: false)
          .range(offset ?? 0, (offset ?? 0) + (limit ?? 20) - 1);

      return response
          .map((itemJson) => ItemModel.fromJson(itemJson))
          .toList();

    } catch (e) {
      if (e is PostgrestException) {
        throw ServerException(message: "Gagal mencari barang (DB Error): ${e.message}");
      }
      throw ServerException(message: "Gagal mencari barang: ${e.toString()}");
    }
  }
  
  @override
  Future<ItemModel> claimItemViaQr({required String qrCodeData, required String claimerId}) async {
    try {
      final response = await supabaseClient.rpc(
        'process_item_claim_by_qr',
        params: {'p_qr_code_data': qrCodeData, 'p_claimer_id': claimerId},
      ).single();
      return ItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: "Gagal mengklaim barang: ${e.message}");
    } catch (e) {
      throw ServerException(message: "Terjadi kesalahan saat klaim: ${e.toString()}");
    }
  }
  
  @override
  Future<void> submitGuestClaim(SubmitGuestClaimParams params) async {
    try {
      await supabaseClient.rpc(
        'process_guest_claim',
        params: {
          'p_item_id': params.itemId,
          'p_security_id': params.securityId,
          'p_guest_details': params.guestDetails,
        },
      );
    } on PostgrestException catch (e) {
      throw ServerException(message: "Gagal memproses klaim tamu: ${e.message}");
    } catch (e) {
      throw ServerException(message: "Terjadi kesalahan saat proses klaim: ${e.toString()}");
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
      };

      if (newImageFile != null) {
        final newImageUrl = await _uploadImage(newImageFile, item.id);
        if (newImageUrl != null) {
          dataToUpdate['image_url'] = newImageUrl;
        }
      }

      final response = await supabaseClient
          .from('items')
          .update(dataToUpdate)
          .eq('id', item.id)
          .select('*, reporterProfile:profiles!items_reporter_id_fkey(*), category:categories(*), location:locations(*)')
          .single();
      return ItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: "Gagal memperbarui barang: ${e.message}");
    } catch (e) {
      throw ServerException(message: "Terjadi kesalahan: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      await supabaseClient.from('items').delete().eq('id', itemId);
    } on PostgrestException catch (e) {
      throw ServerException(message: "Gagal menghapus barang: ${e.message}");
    } catch (e) {
      throw ServerException(message: "Terjadi kesalahan saat menghapus barang: ${e.toString()}");
    }
  }
}
