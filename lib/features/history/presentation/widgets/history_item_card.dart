import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:olivia/core/utils/app_colors.dart';
// Hapus import enums jika tidak digunakan di file ini
// import 'package:olivia/core/utils/enums.dart'; 
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/presentation/pages/item_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    String claimerName = item.claimerProfile?.fullName ?? 'Seseorang';
    String reporterName = item.reporterProfile?.fullName ?? 'Seseorang';

    // --- PERBAIKAN FINAL ---
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1), 
      color: Colors.white, 
      // --- TAMBAHAN INI UNTUK MENGATASI WARNA TINT UNGU/PINK DARI MATERIAL 3 ---
      surfaceTintColor: Colors.white, 
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            ItemDetailPage.routeName,
            pathParameters: {'itemId': item.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar
                  ClipRRect(
                     borderRadius: BorderRadius.circular(8),
                     child: Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              // Menambahkan frameBuilder untuk loading dan error
                              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded) return child;
                                return AnimatedOpacity(
                                  opacity: frame == null ? 0 : 1,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                  child: child,
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                 return Icon(Icons.image_not_supported, color: Colors.grey[400], size: 24);
                              },
                            )
                          : Icon(Icons.image_not_supported, color: Colors.grey[400], size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info Utama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColor),
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
                    label: const Text('Diklaim', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.redAccent.shade200,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),
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
                    value: DateFormat('dd MMM yy, HH:mm', 'id_ID').format(item.claimedAt!),
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
                    value: DateFormat('dd MMM yy, HH:mm', 'id_ID').format(item.claimedAt!),
                  ),
                  _buildHistoryDetailRow(
                    icon: Icons.report_outlined,
                    label: 'Anda Laporkan Pada',
                    value: DateFormat('dd MMM yy, HH:mm', 'id_ID').format(item.reportedAt!),
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
          Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.subtleTextColor)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textColor),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
