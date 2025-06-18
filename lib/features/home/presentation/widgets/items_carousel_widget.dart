import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/home/domain/entities/item_preview.dart';
import 'package:olivia/features/item/presentation/pages/item_detail_page.dart';

class ItemsCarouselWidget extends StatelessWidget {
  final String title;
  final List<ItemPreviewEntity> items;
  final VoidCallback onSeeAll;

  const ItemsCarouselWidget({
    super.key,
    required this.title,
    required this.items,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 24.0,
            bottom: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Semua',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250, // Increased height to accommodate content
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            scrollDirection: Axis.horizontal,
            itemCount:
                items.length > 6
                    ? 6
                    : items.length,
            itemBuilder: (context, index) {
              return _buildItemCard(context, items[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, ItemPreviewEntity item) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          ItemDetailPage.routeName,
          pathParameters: {'itemId': item.id},
        );
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with fixed height
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(item.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: item.imageUrl == null || item.imageUrl!.isEmpty
                      ? Colors.grey[300]
                      : null,
                ),
                child: item.imageUrl == null || item.imageUrl!.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        ),
                      )
                    : null,
              ),
              // Flexible content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.categoryName ?? 'Tanpa Kategori',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.locationName ?? 'Tanpa Lokasi',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(), // Push chip to bottom
                      Chip(
                        label: Text(
                          item.reportType == ReportType.penemuan
                              ? 'PENEMUAN'
                              : 'Hilang',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: item.reportType == ReportType.penemuan
                            ? Colors.green
                            : Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 0,
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}