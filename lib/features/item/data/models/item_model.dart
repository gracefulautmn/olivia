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
    super.reporterProfile,
    super.category,
    super.location,
    super.claimerProfile, // Tambahkan di constructor
    super.claimedAt,      // Tambahkan di constructor
    super.claimId,        // Tambahkan di constructor
  });

 factory ItemModel.fromJson(Map<String, dynamic> json) {
  UserProfileModel? claimer;
  DateTime? claimedTime;
  String? claimIdentifier;

  // Cek apakah ada data 'claims' (hasil join)
  dynamic claimsData = json['claims'];
  if (claimsData != null) {
    Map<String, dynamic> claimJson;
    if (claimsData is List && claimsData.isNotEmpty) {
      claimJson = claimsData.first as Map<String, dynamic>;
    } else if (claimsData is Map) {
      claimJson = claimsData as Map<String, dynamic>;
    } else {
      claimJson = {}; // Default jika format tidak sesuai
    }

    if (claimJson.isNotEmpty) {
      claimIdentifier = claimJson['id']?.toString();
      if (claimJson['claimed_at'] != null) {
        try {
          claimedTime = DateTime.parse(claimJson['claimed_at'] as String);
        } catch (e) {
          print("Error parsing claimed_at: $e");
          claimedTime = null;
        }
      }
      
      if (claimJson['profiles'] != null) {
        try {
          claimer = UserProfileModel.fromJson(claimJson['profiles'] as Map<String, dynamic>);
        } catch (e) {
          print("Error parsing claimer profile: $e");
          claimer = null;
        }
      } else if (claimJson['claimer_id'] != null && json['claimer_profile_data'] != null) {
        try {
          claimer = UserProfileModel.fromJson(json['claimer_profile_data'] as Map<String, dynamic>);
        } catch (e) {
          print("Error parsing claimer profile data: $e");
          claimer = null;
        }
      }
    }
  }

  // Add null safety checks for all required fields
  try {
    return ItemModel(
      id: json['id']?.toString() ?? '',
      reporterId: json['reporter_id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? 'Unknown Item',
      description: json['description']?.toString(),
      categoryId: json['category_id']?.toString(),
      locationId: json['location_id']?.toString(),
      reportType: json['report_type'] != null 
          ? reportTypeFromString(json['report_type'] as String)
          : ReportType.kehilangan, // atau default value yang sesuai
      status: json['status'] != null 
          ? itemStatusFromString(json['status'] as String)
          : ItemStatus.hilang, // atau default value yang sesuai
      imageUrl: json['image_url']?.toString(),
      qrCodeData: json['qr_code_data']?.toString(),
      reportedAt: json['reported_at'] != null
          ? DateTime.parse(json['reported_at'] as String)
          : DateTime.now(), // fallback to current time
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      reporterProfile: json['profiles'] != null
          ? _safeParseUserProfile(json['profiles'])
          : null,
      category: json['categories'] != null
          ? _safeParseCategoryModel(json['categories'])
          : null,
      location: json['locations'] != null
          ? _safeParseLocationModel(json['locations'])
          : null,
      claimerProfile: claimer,
      claimedAt: claimedTime,
      claimId: claimIdentifier,
    );
  } catch (e) {
    print("Error creating ItemModel from JSON: $e");
    print("Problematic JSON: $json");
    rethrow;
  }
}

// Helper methods untuk parsing yang aman
static UserProfileModel? _safeParseUserProfile(dynamic profileData) {
  try {
    if (profileData is Map<String, dynamic>) {
      return UserProfileModel.fromJson(profileData);
    }
    return null;
  } catch (e) {
    print("Error parsing user profile: $e");
    return null;
  }
}

static CategoryModel? _safeParseCategoryModel(dynamic categoryData) {
  try {
    if (categoryData is Map<String, dynamic>) {
      return CategoryModel.fromJson(categoryData);
    }
    return null;
  } catch (e) {
    print("Error parsing category: $e");
    return null;
  }
}

  static LocationModel? _safeParseLocationModel(dynamic locationData) {
    try {
      if (locationData is Map<String, dynamic>) {
        return LocationModel.fromJson(locationData);
      }
      return null;
    } catch (e) {
      print("Error parsing location: $e");
      return null;
    }
  }
}