import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/data/models/user_profile_model.dart';
import 'package:olivia/features/home/data/models/category_model.dart';
import 'package:olivia/features/home/data/models/location_model.dart';
import 'package:olivia/features/item/domain/entities/item.dart';

// Helper di luar kelas atau di file terpisah
ReportType reportTypeFromString(String val) => ReportType.values.firstWhere((e) => e.name == val, orElse: () => ReportType.kehilangan);
ItemStatus itemStatusFromString(String val) => ItemStatus.values.firstWhere((e) => e.name == val, orElse: () => ItemStatus.hilang);

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.id,
    required super.reporterId,
    required super.itemName,
    required super.reportType,
    required super.status,
    super.reportedAt,
    super.updatedAt,
    super.description,
    super.categoryId,
    super.locationId,
    super.imageUrl,
    super.qrCodeData,
    super.latitude,
    super.longitude,
    super.category,
    super.location,
    super.reporterProfile,
    // Menambahkan properti baru dari entity
    super.claimedAt,
    super.claimerProfile,
    super.guestClaimerDetails,
  });
  
  factory ItemModel.fromEntity(ItemEntity entity) {
    return ItemModel(
      id: entity.id,
      reporterId: entity.reporterId,
      itemName: entity.itemName,
      reportType: entity.reportType,
      status: entity.status,
      reportedAt: entity.reportedAt,
      updatedAt: entity.updatedAt,
      description: entity.description,
      categoryId: entity.categoryId,
      locationId: entity.locationId,
      imageUrl: entity.imageUrl,
      qrCodeData: entity.qrCodeData,
      latitude: entity.latitude,
      longitude: entity.longitude,
      category: entity.category,
      location: entity.location,
      reporterProfile: entity.reporterProfile,
      claimedAt: entity.claimedAt,
      claimerProfile: entity.claimerProfile,
      guestClaimerDetails: entity.guestClaimerDetails,
    );
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    // --- PERBAIKAN UTAMA DI SINI ---
    Map<String, dynamic>? firstClaim;
    final claimsData = json['claims'];

    // Cek jika 'claims' adalah List dan tidak kosong
    if (claimsData is List && claimsData.isNotEmpty) {
      firstClaim = claimsData.first as Map<String, dynamic>?;
    } 
    // Cek jika 'claims' adalah Map (objek tunggal)
    else if (claimsData is Map<String, dynamic>) {
      firstClaim = claimsData;
    }

    return ItemModel(
      id: json['id']?.toString() ?? '',
      reporterId: json['reporter_id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? 'Tanpa Nama',
      description: json['description'],
      categoryId: json['category_id'],
      locationId: json['location_id'],
      reportType: reportTypeFromString(json['report_type']?.toString() ?? 'kehilangan'),
      status: itemStatusFromString(json['status']?.toString() ?? 'hilang'),
      imageUrl: json['image_url'],
      qrCodeData: json['qr_code_data'],
      reportedAt: json['reported_at'] == null ? null : DateTime.tryParse(json['reported_at'].toString()),
      updatedAt: json['updated_at'] == null ? null : DateTime.tryParse(json['updated_at'].toString()),
      latitude: json['latitude'],
      longitude: json['longitude'],
      
      category: json['category'] == null ? null : CategoryModel.fromJson(json['category']),
      location: json['location'] == null ? null : LocationModel.fromJson(json['location']),
      reporterProfile: json['reporterProfile'] == null ? null : UserProfileModel.fromJson(json['reporterProfile']),
      
      // Mengambil data dari objek klaim yang sudah diproses dengan aman
      claimedAt: firstClaim?['claimed_at'] == null ? null : DateTime.tryParse(firstClaim!['claimed_at'].toString()),
      guestClaimerDetails: firstClaim?['guest_claimer_details'] as String?,
      claimerProfile: firstClaim?['claimerProfile'] == null ? null : UserProfileModel.fromJson(firstClaim!['claimerProfile']),
    );
  }
}
