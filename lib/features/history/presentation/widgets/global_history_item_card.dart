import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:olivia/features/history/domain/entities/claim_history_entry.dart';
import 'package:olivia/features/item/presentation/pages/item_detail_page.dart';

class GlobalHistoryItemCard extends StatelessWidget {
  final ClaimHistoryEntry entry;

  const GlobalHistoryItemCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // --- PERBAIKAN 1: Tentukan apakah ini klaim oleh tamu ---
    final bool isGuestClaim = entry.claimerProfile == null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigasi ke detail item saat card diklik
          context.pushNamed(
            ItemDetailPage.routeName,
            pathParameters: {'itemId': entry.item.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- GAMBAR BARANG ---
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: entry.item.imageUrl != null &&
                          entry.item.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(entry.item.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: entry.item.imageUrl == null ||
                          entry.item.imageUrl!.isEmpty
                      ? Colors.grey[200]
                      : null,
                ),
                child: entry.item.imageUrl == null ||
                        entry.item.imageUrl!.isEmpty
                    ? Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // --- DETAIL INFORMASI ---
              Expanded(
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(entry.claimedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Detail Klaim
                    _buildInfoRow(
                      context,
                      icon: Icons.security_outlined, // Ikon untuk petugas
                      label: 'Diproses oleh',
                      value: entry.securityProfile.fullName,
                    ),
                    const SizedBox(height: 4),
                    // --- PERBAIKAN 2: Tampilkan info pengklaim secara dinamis ---
                    _buildInfoRow(
                      context,
                      icon: isGuestClaim ? Icons.person_pin_outlined : Icons.person_search_outlined,
                      label: 'Diklaim oleh',
                      // Jika tamu, tampilkan detail tamu. Jika bukan, tampilkan nama profil.
                      value: isGuestClaim 
                          ? 'Tamu (Non-Akun)' 
                          : entry.claimerProfile!.fullName,
                    ),
                    // Tampilkan detail tamu jika ada
                    if (isGuestClaim && entry.guestClaimerDetails != null && entry.guestClaimerDetails!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 22.0), // Indentasi
                        child: Text(
                          entry.guestClaimerDetails!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
