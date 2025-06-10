import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/data/models/user_profile_model.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart'; // Asumsi modelnya ada di entitas
import 'package:olivia/features/home/data/models/category_model.dart';
import 'package:olivia/features/home/data/models/location_model.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
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
    required super.reportedAt,
    required super.updatedAt,
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
        reporterProfile: entity.reporterProfile);
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      reporterId: json['reporter_id'],
      itemName: json['item_name'],
      description: json['description'],
      categoryId: json['category_id'],
      locationId: json['location_id'],
      reportType: reportTypeFromString(json['report_type']),
      status: itemStatusFromString(json['status']),
      imageUrl: json['image_url'],
      qrCodeData: json['qr_code_data'],
      reportedAt: DateTime.parse(json['reported_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      
      category: json['categories'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['categories'])
          : null,
      location: json['locations'] is Map<String, dynamic>
          ? LocationModel.fromJson(json['locations'])
          : null,
      reporterProfile: json['profiles'] is Map<String, dynamic>
          ? UserProfileModel.fromJson(json['profiles']) // Asumsi UserProfile punya fromJson
          : null,
    );
  }
}
