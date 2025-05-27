import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/data/models/user_profile_model.dart';
import 'package:olivia/features/home/data/models/category_model.dart';
import 'package:olivia/features/home/data/models/location_model.dart';
import 'package:olivia/features/item/domain/entities/item.dart';

class ItemModel extends ItemEntity {
  const ItemModel({
    required super.id,
    required super.reporterId,
    required super.itemName,
    super.description,
    super.categoryId,
    super.locationId,
    required super.reportType,
    required super.status,
    super.imageUrl,
    super.qrCodeData,
    required super.reportedAt,
    super.updatedAt,
    super.latitude,
    super.longitude,
    super.reporterProfile, // Akan di-populate dari UserProfileModel
    super.category, // Akan di-populate dari CategoryModel
    super.location, // Akan di-populate dari LocationModel
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      itemName: json['item_name'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      locationId: json['location_id'] as String?,
      reportType: reportTypeFromString(json['report_type'] as String),
      status: itemStatusFromString(json['status'] as String),
      imageUrl: json['image_url'] as String?,
      qrCodeData: json['qr_code_data'] as String?,
      reportedAt: DateTime.parse(json['reported_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      // Populate related models jika ada di JSON (hasil join)
      reporterProfile:
          json['profiles'] != null
              ? UserProfileModel.fromJson(
                json['profiles'] as Map<String, dynamic>,
              )
              : null,
      category:
          json['categories'] != null
              ? CategoryModel.fromJson(
                json['categories'] as Map<String, dynamic>,
              )
              : null,
      location:
          json['locations'] != null
              ? LocationModel.fromJson(
                json['locations'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Biasanya tidak dikirim saat create, Supabase auto-generate
      'reporter_id': reporterId,
      'item_name': itemName,
      'description': description,
      'category_id': categoryId,
      'location_id': locationId,
      'report_type': reportTypeToString(reportType),
      'status': itemStatusToString(status),
      'image_url': imageUrl,
      'qr_code_data': qrCodeData,
      'reported_at':
          reportedAt
              .toIso8601String(), // Hanya untuk update, create pakai default
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Saat membuat item baru, beberapa field tidak perlu dikirim
  Map<String, dynamic> toJsonForCreate() {
    return {
      'reporter_id': reporterId,
      'item_name': itemName,
      'description': description,
      'category_id': categoryId,
      'location_id': locationId,
      'report_type': reportTypeToString(reportType),
      'status': itemStatusToString(status),
      'image_url': imageUrl, // Akan diisi setelah upload
      'qr_code_data': qrCodeData, // Akan di-generate jika item penemuan
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
