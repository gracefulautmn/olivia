import 'package:equatable/equatable.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart'; // Untuk info pelapor
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';

class ItemEntity extends Equatable {
  final String id;
  final String reporterId; // ID dari UserProfile
  final String itemName;
  final String? description;
  final String? categoryId;
  final String? locationId;
  final ReportType reportType;
  final ItemStatus status;
  final String? imageUrl;
  final String? qrCodeData; // Hanya untuk item 'penemuan'
  final DateTime reportedAt;
  final DateTime? updatedAt;
  final double? latitude;
  final double? longitude;

  // Opsional: Untuk menampilkan info detail dari relasi
  final UserProfile? reporterProfile;
  final CategoryEntity? category;
  final LocationEntity? location;

  const ItemEntity({
    required this.id,
    required this.reporterId,
    required this.itemName,
    this.description,
    this.categoryId,
    this.locationId,
    required this.reportType,
    required this.status,
    this.imageUrl,
    this.qrCodeData,
    required this.reportedAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.reporterProfile,
    this.category,
    this.location,
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
    reporterProfile,
    category,
    location,
  ];
}
