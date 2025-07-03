import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/common_widgets/custom_button.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/presentation/bloc/manual_claim_bloc.dart';

class ManualClaimPage extends StatefulWidget {
  const ManualClaimPage({super.key});

  static const String routeName = '/manual-claim';

  @override
  State<ManualClaimPage> createState() => _ManualClaimPageState();
}

class _ManualClaimPageState extends State<ManualClaimPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedItemId;
  final _guestNameController = TextEditingController();
  final _guestContactController = TextEditingController();
  final _guestNotesController = TextEditingController();

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestContactController.dispose();
    _guestNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ManualClaimBloc>()..add(FetchAvailableItems()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Proses Klaim Manual'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: BlocConsumer<ManualClaimBloc, ManualClaimState>(
          listener: (context, state) {
            if (state is ManualClaimSubmitSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Klaim berhasil diproses!'),
                    backgroundColor: Colors.green,
                  ),
                );
              // Kembali ke halaman utama atau riwayat setelah sukses
              context.pop();
            }
            if (state is ManualClaimSubmitFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('Gagal memproses klaim: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
            }
          },
          builder: (context, state) {
            if (state is ManualClaimLoading) {
              return const Center(child: LoadingIndicator(message: 'Memuat data barang...'));
            }
            if (state is ManualClaimLoadFailure) {
              return Center(
                child: ErrorDisplayWidget(
                  message: state.message,
                  onRetry: () => context.read<ManualClaimBloc>().add(FetchAvailableItems()),
                ),
              );
            }
            if (state is ManualClaimLoadSuccess) {
              return _buildForm(context, state.availableItems, state is ManualClaimSubmitting);
            }
            return const Center(child: Text("Silakan mulai dengan memuat data."));
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<ItemEntity> items, bool isSubmitting) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada barang temuan yang tersedia untuk diklaim saat ini.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Pilih Barang yang Akan Diklaim',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedItemId,
            hint: const Text('Pilih barang...'),
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item.id,
                child: Text(item.itemName, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedItemId = value;
              });
            },
            validator: (value) => value == null ? 'Silakan pilih barang' : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Informasi Tamu Pengklaim',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _guestNameController,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap Tamu',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                (value ?? '').isEmpty ? 'Nama tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _guestContactController,
            decoration: const InputDecoration(
              labelText: 'Nomor Telepon/Kontak',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) =>
                (value ?? '').isEmpty ? 'Kontak tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _guestNotesController,
            decoration: const InputDecoration(
              labelText: 'Catatan Tambahan (Opsional)',
              prefixIcon: Icon(Icons.notes),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Proses Klaim',
            isLoading: isSubmitting,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final securityUser = context.read<AuthBloc>().state.user;
                if (securityUser != null) {
                  final guestDetails = 
                    'Nama: ${_guestNameController.text}\n'
                    'Kontak: ${_guestContactController.text}\n'
                    'Catatan: ${_guestNotesController.text}';

                  context.read<ManualClaimBloc>().add(
                        SubmitClaimButtonPressed(
                          itemId: _selectedItemId!,
                          securityUser: securityUser,
                          guestDetails: guestDetails,
                        ),
                      );
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Tidak dapat menemukan data petugas.'))
                  );
                }
              }
            },
          )
        ],
      ),
    );
  }
}
