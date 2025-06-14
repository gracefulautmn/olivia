import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart'; // Untuk current user
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart'; // Untuk akses current user
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/presentation/pages/item_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Untuk akses AuthBloc

class HistoryItemCard extends StatelessWidget {
  final ItemEntity item;
  final bool isViewedByClaimer; // true jika tab "Diklaim Saya", false jika tab "Ditemukan Saya"

  const HistoryItemCard({
    super.key,
    required this.item,
    required this.isViewedByClaimer,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final UserProfile? currentUser = authState.user;

    String claimerName = item.claimerProfile?.fullName ?? 'Seseorang';
    String reporterName = item.reporterProfile?.fullName ?? 'Seseorang';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            ItemDetailPage.routeName,
            pathParameters: {'itemId': item.id},
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(item.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: item.imageUrl == null || item.imageUrl!.isEmpty
                          ? Colors.grey[200]
                          : null,
                    ),
                    child: item.imageUrl == null || item.imageUrl!.isEmpty
                        ? Icon(Icons.image_not_supported, color: Colors.grey[400], size: 24)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Info Utama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.category?.name ?? 'Tanpa Kategori',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.location?.name ?? 'Tanpa Lokasi',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status (selalu 'Diklaim' di halaman riwayat)
                  Chip(
                    label: const Text('Diklaim', style: TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: Colors.redAccent.shade200,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 0.5),
              // Informasi Klaim/Temuan
              if (isViewedByClaimer) ...[ // Tab "Diklaim Saya"
                _buildHistoryDetailRow(
                  icon: Icons.person_pin_circle_outlined,
                  label: 'Ditemukan oleh',
                  value: reporterName,
                ),
                if (item.claimedAt != null)
                  _buildHistoryDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Tanggal Diklaim',
                    value: DateFormat('dd MMM yyyy, HH:mm').format(item.claimedAt!),
                  ),
              ] else ...[ // Tab "Ditemukan Saya"
                 _buildHistoryDetailRow(
                  icon: Icons.person_search_outlined,
                  label: 'Diklaim oleh',
                  value: claimerName,
                ),
                if (item.claimedAt != null)
                  _buildHistoryDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Tanggal Diklaim',
                    value: DateFormat('dd MMM yyyy, HH:mm').format(item.claimedAt!),
                  ),
                 _buildHistoryDetailRow(
                    icon: Icons.report_outlined,
                    label: 'Anda Laporkan Pada',
                    value: DateFormat('dd MMM yyyy, HH:mm').format(item.reportedAt!),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.subtleTextColor),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13, color: AppColors.subtleTextColor)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}