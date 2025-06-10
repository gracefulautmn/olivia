import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:olivia/features/history/domain/entities/claim_history_entry.dart';

class GlobalHistoryItemCard extends StatelessWidget {
  final ClaimHistoryEntry entry;

  const GlobalHistoryItemCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Atas: Nama Barang dan Tanggal Klaim
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entry.item.itemName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(entry.claimedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            // Detail Klaim
            _buildInfoRow(
              context,
              icon: Icons.person_search_outlined,
              label: 'Ditemukan oleh (Keamanan)',
              value: entry.securityProfile.fullName,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              icon: Icons.person_pin_circle_outlined,
              label: 'Diklaim oleh',
              value: entry.claimerProfile.fullName,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              icon: Icons.category_outlined,
              label: 'Kategori Barang',
              value: entry.item.category?.name ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
