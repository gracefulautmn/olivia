import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/home/domain/entities/item_preview.dart';

class ItemPreviewModel extends ItemPreviewEntity {
  const ItemPreviewModel({
    required super.id,
    required super.itemName,
    super.imageUrl,
    required super.reportType,
    super.categoryName,
    super.locationName,
  });

  factory ItemPreviewModel.fromJson(Map<String, dynamic> json) {
    return ItemPreviewModel(
      id: json['id'] as String,
      itemName: json['item_name'] as String,
      imageUrl: json['image_url'] as String?,
      reportType: reportTypeFromString(json['report_type'] as String),
      // Asumsi join untuk mendapatkan nama kategori dan lokasi, atau query terpisah
      categoryName:
          json['categories'] != null
              ? json['categories']['name'] as String?
              : null,
      locationName:
          json['locations'] != null
              ? json['locations']['name'] as String?
              : null,
    );
  }

  // toJson tidak terlalu relevan untuk preview yang hanya di-fetch
}
