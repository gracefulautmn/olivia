import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/usecases/get_item_details.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Untuk menampilkan QR Code

// BLoC untuk Item Detail
class ItemDetailCubit extends Cubit<ItemDetailState> {
  final GetItemDetails _getItemDetailsUseCase;

  ItemDetailCubit(this._getItemDetailsUseCase) : super(ItemDetailInitial());

  Future<void> fetchItemDetails(String itemId) async {
    emit(ItemDetailLoading());
    final result = await _getItemDetailsUseCase(
      GetItemDetailsParams(itemId: itemId),
    );
    result.fold(
      (failure) => emit(ItemDetailError(failure.message)),
      (item) => emit(ItemDetailLoaded(item)),
    );
  }
}

// State untuk Item Detail
abstract class ItemDetailState extends Equatable {
  const ItemDetailState();
  @override
  List<Object> get props => [];
}

class ItemDetailInitial extends ItemDetailState {}

class ItemDetailLoading extends ItemDetailState {}

class ItemDetailLoaded extends ItemDetailState {
  final ItemEntity item;
  const ItemDetailLoaded(this.item);
  @override
  List<Object> get props => [item];
}

class ItemDetailError extends ItemDetailState {
  final String message;
  const ItemDetailError(this.message);
  @override
  List<Object> get props => [message];
}

class ItemDetailPage extends StatelessWidget {
  final String itemId;
  // final ItemEntity? item; // Bisa dilewatkan sebagai extra dari GoRouter untuk tampilan awal cepat

  const ItemDetailPage({super.key, required this.itemId /*, this.item */});

  static const String routeName = '/item-detail/:itemId'; // path param

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ItemDetailCubit>()..fetchItemDetails(itemId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail Barang')),
        body: BlocBuilder<ItemDetailCubit, ItemDetailState>(
          builder: (context, state) {
            if (state is ItemDetailLoading) {
              return const Center(child: LoadingIndicator());
            }
            if (state is ItemDetailError) {
              return Center(
                child: ErrorDisplayWidget(
                  message: state.message,
                  onRetry: () {
                    context.read<ItemDetailCubit>().fetchItemDetails(itemId);
                  },
                ),
              );
            }
            if (state is ItemDetailLoaded) {
              return _buildItemDetailContent(context, state.item);
            }
            return const Center(child: Text('Memuat detail barang...'));
          },
        ),
      ),
    );
  }

  Widget _buildItemDetailContent(BuildContext context, ItemEntity item) {
    final authState = context.watch<AuthBloc>().state;
    final currentUser = authState.user;
    final bool isReporter = currentUser?.id == item.reporterId;
    final bool canChat =
        currentUser != null && !isReporter; // Bisa chat jika bukan pelapor

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Gambar Barang
        if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              item.imageUrl!,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            ),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 60,
                color: Colors.grey,
              ),
            ),
          ),
        const SizedBox(height: 20),

        // Nama Barang
        Text(
          item.itemName,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Status dan Jenis Laporan
        Row(
          children: [
            Chip(
              label: Text(
                item.reportType == ReportType.penemuan ? 'Penemuan' : 'Kehilangan',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor:
                  item.reportType == ReportType.penemuan
                      ? AppColors.primaryColor
                      : Colors.orange,
            ),
            const SizedBox(width: 8),
            // Chip(
            //   label: Text(
            //     item.status == ItemStatus.ditemukan_tersedia
            //         ? 'Tersedia'
            //         : item.status == ItemStatus.ditemukan_diklaim
            //         ? 'Sudah Diklaim'
            //         : 'Masih Hilang',
            //     style: TextStyle(
            //       color:
            //           item.status == ItemStatus.ditemukan_diklaim
            //               ? Colors.white
            //               : Colors.black87,
            //     ),
            //   ),
            //   backgroundColor:
            //       item.status == ItemStatus.ditemukan_diklaim
            //           ? Colors.redAccent
            //           : Colors.grey[300],
            // ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),

        // Detail Informasi
        _buildDetailRow(
          Icons.category_outlined,
          'Kategori',
          item.category?.name ?? 'Tidak ada kategori',
        ),
        _buildDetailRow(
          Icons.location_on_outlined,
          'Lokasi ${item.reportType == ReportType.penemuan ? "Penemuan" : "Terakhir Dilihat"}',
          item.location?.name ?? 'Tidak ada lokasi',
        ),
        _buildDetailRow(
          Icons.person_outline,
          'Dilaporkan oleh',
          item.reporterProfile?.fullName ?? 'Anonim',
        ),
        _buildDetailRow(
          Icons.calendar_today_outlined,
          'Tanggal Lapor',
          DateFormat('dd MMM yyyy, HH:mm').format(item.reportedAt!),
        ),

        if (item.description != null && item.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Deskripsi:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            item.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 20),

        // QR Code (jika item temuan dan belum diklaim)
        if (item.reportType == ReportType.penemuan &&
            item.status == ItemStatus.ditemukan_tersedia &&
            item.qrCodeData != null &&
            item.qrCodeData!.isNotEmpty &&
            isReporter) // Hanya reporter yang bisa lihat QR code untuk item temuannya
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'QR Code untuk Klaim Barang',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Perlihatkan QR Code ini kepada orang yang merasa kehilangan barang ini untuk proses klaim.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    // Menggunakan qr_flutter
                    data: item.qrCodeData!,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                    errorStateBuilder: (cxt, err) {
                      return const Center(
                        child: Text(
                          'Uh oh! Something went wrong...',
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Tombol Aksi (Chat, Edit, Hapus - tergantung user)
        if (canChat)
          ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(
              'Chat Pelapor (${item.reporterProfile?.fullName ?? ''})',
            ),
            onPressed: () {
              // Navigasi ke halaman chat, perlu membuat chat room jika belum ada
              // Anda perlu use case createOrGetChatRoom
              if (currentUser != null && item.reporterProfile != null) {
                context.pushNamed(
                  ChatDetailPage.routeName,
                  pathParameters: {
                    'chatRoomId':
                        'new', // 'new' untuk indikasi buat baru, atau ID jika sudah ada
                  },
                  queryParameters: {
                    'recipientId': item.reporterId,
                    'recipientName': item.reporterProfile!.fullName,
                    'itemId': item.id, // Kaitkan chat dengan item ini
                  },
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),

        if (isReporter && item.status != ItemStatus.ditemukan_diklaim) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Laporan'),
            onPressed: () {
              // TODO: Navigasi ke halaman edit laporan
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur edit belum diimplementasikan'),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: const BorderSide(color: AppColors.primaryColor),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text(
              'Hapus Laporan',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              // TODO: Tampilkan dialog konfirmasi dan panggil use case delete item
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur hapus belum diimplementasikan'),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
