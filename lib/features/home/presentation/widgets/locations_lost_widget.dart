import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/item/presentation/pages/search_results_page.dart';

class LocationsListWidget extends StatelessWidget {
  final List<LocationEntity> locations;
  const LocationsListWidget({super.key, required this.locations});

  IconData _getIconForLocation(String locationName) {
    // Contoh sederhana, bisa diperluas
    String lowerCaseName = locationName.toLowerCase();
    if (lowerCaseName.contains('gedung')) return Icons.business_outlined;
    if (lowerCaseName.contains('parkir')) return Icons.local_parking_outlined;
    if (lowerCaseName.contains('kantin')) return Icons.restaurant_outlined;
    if (lowerCaseName.contains('masjid')) return Icons.mosque_outlined;
    if (lowerCaseName.contains('perpustakaan'))
      return Icons.local_library_outlined;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> locationWidgets = [];
    int displayCount = locations.length > 4 ? 3 : locations.length;

    for (int i = 0; i < displayCount; i++) {
      locationWidgets.add(_buildLocationItem(context, locations[i]));
    }

    if (locations.length > 4) {
      locationWidgets.add(_buildMoreItem(context));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 20.0,
            bottom: 8.0,
          ), // Tambah top padding
          child: Text(
            'Lokasi Populer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            scrollDirection: Axis.horizontal,
            children: locationWidgets,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationItem(BuildContext context, LocationEntity location) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          SearchResultsPage.routeName,
          queryParameters: {
            'locationId': location.id,
            'locationName': location.name,
          },
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.secondaryColor.withOpacity(0.1),
              child: Icon(
                _getIconForLocation(location.name),
                size: 28,
                color: AppColors.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              location.name,
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
