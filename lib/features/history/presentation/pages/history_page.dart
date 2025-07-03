import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/common_widgets/empty_data_widget.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/history/presentation/bloc/global_history_bloc.dart';
import 'package:olivia/features/history/presentation/bloc/my_reports_bloc.dart';
import 'package:olivia/features/history/presentation/widgets/global_history_item_card.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/presentation/widgets/item_list_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  static const String routeName = '/history';

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- PERUBAHAN PADA APPBAR ---
      appBar: AppBar(
        backgroundColor: Colors.white, // Latar belakang AppBar menjadi putih
        foregroundColor: Colors.black, // Warna default untuk ikon (seperti tombol kembali)
        title: const Text(
          'Riwayat',
          style: TextStyle(color: Colors.black), // Teks judul menjadi hitam
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,      // Warna teks untuk tab yang aktif
          unselectedLabelColor: Colors.grey, // Warna teks untuk tab yang tidak aktif
          indicatorColor: Colors.blueAccent, // Warna garis indikator
          tabs: const [
            Tab(text: 'Klaim'),
            Tab(text: 'Laporan Saya'),
          ],
        ),
      ),
      // --- PERUBAHAN PADA BODY DENGAN GRADIENT ---
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Color(0xFFE3F2FD), // Biru muda di atas
              Color(0xFF81D4FA), // Biru medium
              Color(0xFF4FC3F7), // Biru lebih gelap di bawah
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: const [
            GlobalClaimHistoryView(),
            MyLostReportsView(),
          ],
        ),
      ),
    );
  }
}

// --- Widget untuk Tab Riwayat Klaim Global ---
class GlobalClaimHistoryView extends StatelessWidget {
  const GlobalClaimHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (Kode ini tidak perlu diubah)
    return BlocProvider(
      create: (context) => sl<GlobalHistoryBloc>()..add(LoadGlobalHistory()),
      child: BlocBuilder<GlobalHistoryBloc, GlobalHistoryState>(
        builder: (context, state) {
          if (state is GlobalHistoryLoading) {
            return const Center(child: LoadingIndicator(message: 'Memuat riwayat...'));
          }
          if (state is GlobalHistoryFailure) {
            return Center(child: ErrorDisplayWidget(message: state.message, onRetry: () => context.read<GlobalHistoryBloc>().add(LoadGlobalHistory())));
          }
          if (state is GlobalHistoryLoaded) {
            if (state.historyEntries.isEmpty) {
              return const Center(child: EmptyDataWidget(message: 'Belum ada riwayat klaim barang.', icon: Icons.history_rounded));
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<GlobalHistoryBloc>().add(LoadGlobalHistory()),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.historyEntries.length,
                itemBuilder: (context, index) => GlobalHistoryItemCard(entry: state.historyEntries[index]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// --- Widget untuk Tab Laporan Saya (DIPERBAIKI) ---
class MyLostReportsView extends StatelessWidget {
  const MyLostReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select((AuthBloc bloc) => bloc.state.user?.id);

    if (currentUserId == null) {
      return const Center(child: Text('Login untuk melihat laporan Anda.'));
    }

    // PERBAIKAN: Gunakan BLoC yang baru dan lebih sederhana
    return BlocProvider(
      create: (context) => sl<MyReportsBloc>()..add(LoadMyReports(userId: currentUserId)),
      child: BlocBuilder<MyReportsBloc, MyReportsState>(
        builder: (context, state) {
          if (state is MyReportsLoading || state is MyReportsInitial) {
            return const Center(child: LoadingIndicator(message: 'Memuat laporan Anda...'));
          }
          if (state is MyReportsFailure) {
            return Center(
              child: ErrorDisplayWidget(
                message: state.message,
                onRetry: () => context.read<MyReportsBloc>().add(LoadMyReports(userId: currentUserId)),
              ),
            );
          }
          if (state is MyReportsLoaded) {
            if (state.myItems.isEmpty) {
              return const Center(
                child: EmptyDataWidget(
                  message: 'Anda belum pernah membuat laporan.',
                  icon: Icons.find_in_page_outlined,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<MyReportsBloc>().add(LoadMyReports(userId: currentUserId)),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.myItems.length,
                itemBuilder: (context, index) {
                  final ItemEntity item = state.myItems[index];
                  return ItemListCard(item: item);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}