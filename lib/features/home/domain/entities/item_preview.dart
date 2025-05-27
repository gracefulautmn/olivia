import 'package:equatable/equatable.dart';
import 'package:olivia/core/utils/enums.dart'; // Pastikan path ini benar

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
