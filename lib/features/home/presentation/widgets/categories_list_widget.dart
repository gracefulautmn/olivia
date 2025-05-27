import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/item/presentation/pages/search_results_page.dart';

class CategoriesListWidget extends StatelessWidget {
  final List<CategoryEntity> categories;
  const CategoriesListWidget({super.key, required this.categories});

  // Contoh mapping ikon sederhana, idealnya dari backend atau enum
  IconData _getIconForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'elektronik':
        return Icons.devices;
      case 'kunci':
        return Icons.vpn_key_outlined;
      case 'dompet & kartu':
        return Icons.account_balance_wallet_outlined;
      case 'buku & catatan':
        return Icons.book_outlined;
      case 'pakaian':
        return Icons.style_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink(); // Jangan tampilkan apa-apa jika kosong
    }

    List<Widget> categoryWidgets = [];
    int displayCount = categories.length > 4 ? 3 : categories.length;

    for (int i = 0; i < displayCount; i++) {
      categoryWidgets.add(_buildCategoryItem(context, categories[i]));
    }

    if (categories.length > 4) {
      categoryWidgets.add(_buildMoreItem(context));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            'Kategori Barang',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 110, // Sesuaikan tinggi
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            scrollDirection: Axis.horizontal,
            children: categoryWidgets,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryEntity category) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          SearchResultsPage.routeName,
          queryParameters: {
            'categoryId': category.id,
            'categoryName': category.name,
          },
        );
      },
      child: Container(
        width: 80, // Lebar item
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              child: Icon(
                _getIconForCategory(category.name),
                size: 28,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Ke page pencarian tanpa sorting/filter awal
        context.pushNamed(SearchResultsPage.routeName);
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                Icons.more_horiz,
                size: 28,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lainnya',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
