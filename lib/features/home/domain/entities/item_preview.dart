import 'package:equatable/equatable.dart';
import 'package:olivia/core/utils/enums.dart'; // Pastikan path ini benar
import 'package:olivia/features/item/domain/entities/item.dart'; // Impor ItemEntity

class ItemPreviewEntity extends Equatable {
  final String id;
  final String itemName;
  final String? imageUrl;
  final ReportType reportType; // 'kehilangan' atau 'penemuan'
  final String? categoryName; // Opsional, nama kategori
  final String? locationName; // Opsional, nama lokasi

  const ItemPreviewEntity({
    required this.id,
    required this.itemName,
    this.imageUrl,
    required this.reportType,
    this.categoryName,
    this.locationName,
  });

  // ===>>> FACTORY CONSTRUCTOR YANG HILANG, DITAMBAHKAN DI SINI <<<===
  factory ItemPreviewEntity.fromItemEntity(ItemEntity item) {
    return ItemPreviewEntity(
      id: item.id,
      itemName: item.itemName,
      imageUrl: item.imageUrl,
      reportType: item.reportType,
      // Mengambil nama dari objek relasi jika ada
      categoryName: item.category?.name,
      locationName: item.location?.name,
    );
  }

  @override
  List<Object?> get props => [
        id,
        itemName,
        imageUrl,
        reportType,
        categoryName,
        locationName,
      ];
}
