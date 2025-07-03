import 'package:equatable/equatable.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';

class ItemEntity extends Equatable {
  final String id;
  final String reporterId;
  final String itemName;
  final String? description;
  final String? categoryId;
  final String? locationId;
  final ReportType reportType;
  final ItemStatus status;
  final String? imageUrl;
  final String? qrCodeData;
  final DateTime? reportedAt;
  final DateTime? updatedAt;
  final double? latitude;
  final double? longitude;

  // Relational data
  final CategoryEntity? category;
  final LocationEntity? location;
  final UserProfile? reporterProfile;

  // --- PERBAIKAN: Tambahkan field untuk informasi klaim ---
  final DateTime? claimedAt;
  final UserProfile? claimerProfile;
  final String? guestClaimerDetails;

  const ItemEntity({
    required this.id,
    required this.reporterId,
    required this.itemName,
    required this.reportType,
    required this.status,
    this.description,
    this.categoryId,
    this.locationId,
    this.imageUrl,
    this.qrCodeData,
    this.reportedAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.category,
    this.location,
    this.reporterProfile,
    // Tambahkan ke constructor
    this.claimedAt,
    this.claimerProfile,
    this.guestClaimerDetails,
  });

  @override
  List<Object?> get props => [
        id,
        reporterId,
        itemName,
        description,
        categoryId,
        locationId,
        reportType,
        status,
        imageUrl,
        qrCodeData,
        reportedAt,
        updatedAt,
        latitude,
        longitude,
        category,
        location,
        reporterProfile,
        // Tambahkan ke props
        claimedAt,
        claimerProfile,
        guestClaimerDetails,
      ];
}
