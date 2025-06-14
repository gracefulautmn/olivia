import 'package:equatable/equatable.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';

class ItemEntity extends Equatable {
  final String id;
  final String reporterId;
  final String itemName;
  final ReportType reportType;
  final ItemStatus status;
  // PERBAIKAN: Ubah menjadi nullable DateTime?
  final DateTime? reportedAt;
  final DateTime? updatedAt;
  final DateTime? claimedAt;

  // Field opsional
  final String? description;
  final String? categoryId;
  final String? locationId;
  final String? imageUrl;
  final String? qrCodeData;
  final double? latitude;
  final double? longitude;

  // Data dari relasi (join)
  final CategoryEntity? category;
  final LocationEntity? location;
  final UserProfile? reporterProfile;
  final UserProfile? claimerProfile;

  const ItemEntity({
    required this.id,
    required this.reporterId,
    required this.itemName,
    required this.reportType,
    required this.status,
    this.reportedAt, // Sekarang bisa null
    this.updatedAt,  // Sekarang bisa null
    this.claimedAt,
    this.description,
    this.categoryId,
    this.locationId,
    this.imageUrl,
    this.qrCodeData,
    this.latitude,
    this.longitude,
    this.category,
    this.location,
    this.reporterProfile,
    this.claimerProfile,
  });

  @override
  List<Object?> get props => [
        id,
        reporterId,
        itemName,
        reportType,
        status,
        reportedAt,
        updatedAt,
        claimedAt,
        description,
        categoryId,
        locationId,
        imageUrl,
        qrCodeData,
        reporterProfile,
        claimerProfile,
      ];
}
