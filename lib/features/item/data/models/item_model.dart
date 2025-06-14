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
    );
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    // --- PERBAIKAN: Logika parsing yang lebih langsung dan aman ---

    CategoryModel? parsedCategory;
    if (json['categories'] != null && json['categories'] is Map<String, dynamic>) {
      try {
        parsedCategory = CategoryModel.fromJson(json['categories']);
      } catch (e) {
        print('Error parsing nested CategoryModel: $e. Data: ${json['categories']}');
      }
    }

    LocationModel? parsedLocation;
    if (json['locations'] != null && json['locations'] is Map<String, dynamic>) {
      try {
        parsedLocation = LocationModel.fromJson(json['locations']);
      } catch (e) {
        print('Error parsing nested LocationModel: $e. Data: ${json['locations']}');
      }
    }

    UserProfileModel? parsedProfile;
    if (json['profiles'] != null && json['profiles'] is Map<String, dynamic>) {
      try {
        parsedProfile = UserProfileModel.fromJson(json['profiles']);
      } catch (e) {
        print('Error parsing nested UserProfileModel: $e. Data: ${json['profiles']}');
      }
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
      
      category: parsedCategory,
      location: parsedLocation,
      reporterProfile: parsedProfile,
    );
  }
}
