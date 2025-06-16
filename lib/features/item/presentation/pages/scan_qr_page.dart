import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/history/presentation/pages/history_page.dart'; // Impor halaman riwayat
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/usecases/claim_item_via_qr.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// BLoC untuk Scan & Claim
class ScanClaimCubit extends Cubit<ScanClaimState> {
  final ClaimItemViaQr _claimItemUseCase;

  ScanClaimCubit(this._claimItemUseCase) : super(ScanClaimInitial());

  Future<void> claimItem(String qrData, String claimerId) async {
    emit(ScanClaimLoading());
    final result = await _claimItemUseCase(
      ClaimItemParams(qrCodeData: qrData, claimerId: claimerId),
    );
    result.fold(
      (failure) => emit(ScanClaimFailure(failure.message)),
      (item) => emit(ScanClaimSuccess(item)),
    );
  }

  void reset() => emit(ScanClaimInitial());
}

// State untuk Scan & Claim
abstract class ScanClaimState extends Equatable {
  const ScanClaimState();
  @override
  List<Object> get props => [];
}

class ScanClaimInitial extends ScanClaimState {}
class ScanClaimLoading extends ScanClaimState {}
class ScanClaimSuccess extends ScanClaimState {
  final ItemEntity claimedItem;
  const ScanClaimSuccess(this.claimedItem);
  @override
  List<Object> get props => [claimedItem];
}
class ScanClaimFailure extends ScanClaimState {
  final String message;
  const ScanClaimFailure(this.message);
  @override
  List<Object> get props => [message];
}

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  static const String routeName = '/scan-qr';

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BuildContext blocContext, BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String qrData = barcodes.first.rawValue!;
      final authState = BlocProvider.of<AuthBloc>(context, listen: false).state;

      if (authState.status == AuthStatus.authenticated &&
          authState.user != null) {
        setState(() {
          _isProcessing = true;
        });
        BlocProvider.of<ScanClaimCubit>(
          blocContext,
          listen: false,
        ).claimItem(qrData, authState.user!.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login untuk mengklaim barang.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleTorch() async {
    await cameraController.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ScanClaimCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code Barang Temuan'),
          actions: [
            IconButton(
              color: Colors.white,
              icon: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: _isTorchOn ? AppColors.secondaryColor : Colors.grey,
              ),
              iconSize: 32.0,
              onPressed: _toggleTorch,
            ),
          ],
        ),
        body: BlocConsumer<ScanClaimCubit, ScanClaimState>(
          listener: (context, state) {
            if (state is ScanClaimSuccess) {
              // Tampilkan notifikasi sukses
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Barang "${state.claimedItem.itemName}" berhasil diklaim!'),
                  backgroundColor: Colors.green,
                ),
              );
              // PERBAIKAN UTAMA: Arahkan ke halaman riwayat
              context.go(HistoryPage.routeName);
            }
            if (state is ScanClaimFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal mengklaim: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
              // Reset state agar bisa scan lagi
              BlocProvider.of<ScanClaimCubit>(context, listen: false).reset();
            }
            if (state is ScanClaimInitial) {
              // Saat direset, pastikan _isProcessing juga false
              setState(() {
                _isProcessing = false;
              });
            }
          },
          builder: (context, state) {
            // Tampilkan loading jika sedang memproses
            if (state is ScanClaimLoading || _isProcessing) {
              return const Center(
                child: LoadingIndicator(message: 'Memproses klaim...'),
              );
            }

            // Tampilkan UI scanner
            return Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    _handleBarcode(context, capture);
                  },
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.black.withOpacity(0.5),
                    child: const Text(
                      'Arahkan kamera ke QR Code pada barang temuan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
