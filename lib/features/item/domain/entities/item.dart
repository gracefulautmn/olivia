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
  final DateTime reportedAt;
  final DateTime? updatedAt;
  final double? latitude;
  final double? longitude;

  final UserProfile? reporterProfile;
  final CategoryEntity? category;
  final LocationEntity? location;

  // Tambahan untuk informasi klaim (dari tabel claims)
  final UserProfile? claimerProfile; // Profil pengguna yang mengklaim
  final DateTime? claimedAt;        // Waktu barang diklaim
  final String? claimId;            // ID dari tabel claims (opsional)

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
    this.claimerProfile, // Tambahkan di constructor
    this.claimedAt,      // Tambahkan di constructor
    this.claimId,        // Tambahkan di constructor
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
        claimerProfile, // Tambahkan ke props
        claimedAt,      // Tambahkan ke props
        claimId,        // Tambahkan ke props
      ];
}