import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/usecases/delete_item.dart';
import 'package:olivia/features/item/domain/usecases/get_item_details.dart';
import 'package:olivia/features/item/domain/usecases/submit_guest_claim.dart';
import 'package:olivia/features/item/presentation/pages/report_item_page.dart';
import 'package:qr_flutter/qr_flutter.dart';

// === BLoC untuk Item Detail ===
class ItemDetailCubit extends Cubit<ItemDetailState> {
  final GetItemDetails _getItemDetailsUseCase;
  final DeleteItem _deleteItemUseCase;
  final SubmitGuestClaim _submitGuestClaimUseCase;

  ItemDetailCubit(
    this._getItemDetailsUseCase,
    this._deleteItemUseCase,
    this._submitGuestClaimUseCase,
  ) : super(ItemDetailInitial());

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

  // --- PERBAIKAN 1: Tambahkan guestNotes dan perbarui guestDetails ---
  Future<void> claimForGuest({
    required String itemId,
    required String securityId,
    required String guestName,
    required String guestContact,
    required String guestNotes,
  }) async {
    if (state is ItemDetailLoaded) {
      emit(ItemDetailLoading(item: (state as ItemDetailLoaded).item));
    } else {
      emit(ItemDetailLoading());
    }

    final details = 'Nama: ${guestName.trim()}\n'
                    'Kontak: ${guestContact.trim()}\n'
                    'Catatan: ${guestNotes.trim().isNotEmpty ? guestNotes.trim() : '-'}';

    final result = await _submitGuestClaimUseCase(SubmitGuestClaimParams(
      itemId: itemId,
      securityId: securityId,
      guestDetails: details,
    ));
    result.fold(
      (failure) => emit(ItemDetailError("Gagal memproses klaim: ${failure.message}")),
      (_) => emit(ItemDetailGuestClaimSuccess()),
    );
  }

  Future<void> deleteItem(String itemId) async {
    if (state is ItemDetailLoaded) {
      final currentItem = (state as ItemDetailLoaded).item;
      emit(ItemDetailLoading(item: currentItem));
    } else {
      emit(ItemDetailLoading());
    }
    final result = await _deleteItemUseCase(DeleteItemParams(itemId: itemId));
    result.fold(
      (failure) => emit(ItemDetailError("Gagal menghapus laporan: ${failure.message}")),
      (_) => emit(ItemDetailDeleteSuccess()),
    );
  }
}

// === State untuk Item Detail ===
abstract class ItemDetailState extends Equatable {
  const ItemDetailState();
  @override
  List<Object?> get props => [];
}

class ItemDetailInitial extends ItemDetailState {}

class ItemDetailLoading extends ItemDetailState {
  final ItemEntity? item;
  const ItemDetailLoading({this.item});
  @override
  List<Object?> get props => [item];
}

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

class ItemDetailDeleteSuccess extends ItemDetailState {}
class ItemDetailGuestClaimSuccess extends ItemDetailState {}


// === UI Halaman Detail ===
class ItemDetailPage extends StatelessWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  static const String routeName = '/item/:itemId';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemDetailCubit(sl(), sl(), sl())..fetchItemDetails(itemId),
      child: BlocListener<ItemDetailCubit, ItemDetailState>(
        listener: (context, state) {
          if (state is ItemDetailDeleteSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Laporan berhasil dihapus.'),
                  backgroundColor: Colors.green,
                ),
              );
            if (context.canPop()) context.pop();
          }
          if (state is ItemDetailGuestClaimSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Barang berhasil diserahkan kepada tamu.'),
                  backgroundColor: Colors.green,
                ),
              );
            context.read<ItemDetailCubit>().fetchItemDetails(itemId);
          }
          if (state is ItemDetailError) {
            if (context.read<ItemDetailCubit>().state is! ItemDetailLoading) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red,));
              context.read<ItemDetailCubit>().fetchItemDetails(itemId);
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Detail Barang')),
          body: BlocBuilder<ItemDetailCubit, ItemDetailState>(
            builder: (context, state) {
              final currentItem = (state is ItemDetailLoaded) 
                ? state.item 
                : (state is ItemDetailLoading && state.item != null) 
                  ? state.item : null;

              if (state is ItemDetailLoading && currentItem == null) {
                return const Center(child: LoadingIndicator());
              }

              if (state is ItemDetailError && currentItem == null) {
                return Center(
                  child: ErrorDisplayWidget(
                    message: state.message,
                    onRetry: () => context.read<ItemDetailCubit>().fetchItemDetails(itemId),
                  ),
                );
              }

              if (currentItem != null) {
                  return Stack(
                    children: [
                      _buildItemDetailContent(context, currentItem),
                      if (state is ItemDetailLoading)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(child: LoadingIndicator(message: 'Memproses...')),
                        ),
                    ],
                  );
              }
              
              return const SizedBox.shrink(); // Fallback
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItemDetailContent(BuildContext context, ItemEntity item) {
    final authState = context.watch<AuthBloc>().state;
    final currentUser = authState.user;
    final bool isReporter = currentUser?.id == item.reporterId;
    final bool isSecurity = currentUser?.role == UserRole.keamanan;
    
    final bool canChat = currentUser != null && !isReporter;
    final bool canEditOrDelete = isReporter && item.status != ItemStatus.ditemukan_diklaim;
    final bool canShowQr = item.reportType == ReportType.penemuan &&
        item.status == ItemStatus.ditemukan_tersedia &&
        item.qrCodeData != null &&
        item.qrCodeData!.isNotEmpty &&
        isReporter && isSecurity;
    final bool canClaimForGuest = isSecurity && item.reportType == ReportType.penemuan && item.status == ItemStatus.ditemukan_tersedia;


    void _showDeleteConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text('Apakah Anda yakin ingin menghapus laporan ini? Tindakan ini tidak dapat dibatalkan.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<ItemDetailCubit>().deleteItem(item.id);
                },
              ),
            ],
          );
        },
      );
    }

    // --- PERBAIKAN 2: Sesuaikan dialog dengan form di ManualClaimPage ---
    void _showGuestClaimDialog() {
      final formKey = GlobalKey<FormState>();
      final nameController = TextEditingController();
      final contactController = TextEditingController();
      final notesController = TextEditingController(); // Tambahkan controller untuk catatan

      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Serahkan ke Tamu'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap Tamu'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: contactController,
                    decoration: const InputDecoration(labelText: 'Nomor Telepon/Kontak'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Kontak tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Catatan Tambahan (Opsional)'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                child: const Text('Konfirmasi Klaim'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.read<ItemDetailCubit>().claimForGuest(
                      itemId: item.id,
                      securityId: currentUser!.id,
                      guestName: nameController.text,
                      guestContact: contactController.text,
                      guestNotes: notesController.text, // Kirim catatan
                    );
                    Navigator.of(dialogContext).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
          ClipRRect(borderRadius: BorderRadius.circular(12.0), child: Image.network(item.imageUrl!, height: 250, width: double.infinity, fit: BoxFit.cover))
        else
          Container(height: 200, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey))),
        const SizedBox(height: 20),
        Text(item.itemName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(spacing: 8.0, runSpacing: 8.0, children: [
          Chip(
            label: Text(
              item.reportType == ReportType.penemuan ? 'Penemuan' : 'Kehilangan',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: item.reportType == ReportType.penemuan ? AppColors.primaryColor : Colors.orange,
          ),
          if (item.status != ItemStatus.hilang)
            Chip(
              label: Text(
                item.status == ItemStatus.ditemukan_tersedia ? 'Tersedia' : 'Sudah Diklaim',
              ),
              backgroundColor: item.status == ItemStatus.ditemukan_diklaim ? Colors.red.shade100 : Colors.grey[200],
            ),
        ]),
        const SizedBox(height: 16),
        const Divider(),
        _buildDetailRow(context, Icons.category_outlined, 'Kategori', item.category?.name ?? '-'),
        _buildDetailRow(context, Icons.location_on_outlined, 'Lokasi ${item.reportType == ReportType.penemuan ? "Penemuan" : "Terakhir Dilihat"}', item.location?.name ?? '-'),
        _buildDetailRow(context, Icons.person_outline, 'Dilaporkan oleh', item.reporterProfile?.fullName ?? 'Anonim'),
        if (item.reportedAt != null)
          _buildDetailRow(context, Icons.calendar_today_outlined, 'Tanggal Lapor', DateFormat('dd MMM kk:mm').format(item.reportedAt!)),
        
        if (item.status == ItemStatus.ditemukan_diklaim) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.blue[50],
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.blue.shade100)
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Informasi Klaim", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildDetailRow(context, Icons.person_pin_circle_outlined, 'Diklaim oleh', item.claimerProfile?.fullName ?? 'Tamu'),
                  if (item.claimerProfile?.nim != null)
                    _buildDetailRow(context, Icons.badge_outlined, 'NIM', item.claimerProfile!.nim!),
                  if (item.guestClaimerDetails != null)
                     _buildDetailRow(context, Icons.info_outline, 'Detail Tamu', item.guestClaimerDetails!),
                  if (item.claimedAt != null)
                    _buildDetailRow(context, Icons.calendar_today, 'Tanggal Klaim', DateFormat('dd MMM kk:mm').format(item.claimedAt!)),
                  const Divider(height: 20),
                  const Text(
                    'Jika merasa bahwa ini barang milik Anda, segera ke pos keamanan.',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                  )
                ],
              ),
            ),
          ),
        ],

        if (item.description != null && item.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Deskripsi:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(item.description!, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: 20),
        if (canShowQr)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Text('QR Code untuk Klaim Barang', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Perlihatkan QR Code ini kepada pemilik barang untuk proses klaim via scan.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                QrImageView(data: item.qrCodeData!, version: QrVersions.auto, size: 200.0),
              ]),
            ),
          ),
        const SizedBox(height: 24),

        // Tombol Aksi
        if (canChat)
          ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text('Chat Pelapor (${item.reporterProfile?.fullName ?? ''})'),
            onPressed: () {
              if (currentUser != null && item.reporterProfile != null) {
                context.pushNamed(ChatDetailPage.routeName, pathParameters: {'chatRoomId': 'new'}, queryParameters: {'recipientId': item.reporterId, 'recipientName': item.reporterProfile!.fullName, 'itemId': item.id});
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),

        if (canClaimForGuest) ...[
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.handshake_outlined),
            label: const Text('Serahkan ke Tamu'),
            onPressed: _showGuestClaimDialog,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ],
        if (canEditOrDelete) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(icon: const Icon(Icons.edit_outlined), label: const Text('Edit Laporan'), onPressed: () => context.pushNamed(ReportItemPage.routeName, extra: item)),
          const SizedBox(height: 10),
          OutlinedButton.icon(icon: const Icon(Icons.delete_outline, color: Colors.red), label: const Text('Hapus Laporan', style: TextStyle(color: Colors.red)), onPressed: _showDeleteConfirmationDialog),
        ],
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
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
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
