import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/common_widgets/empty_data_widget.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/history/presentation/bloc/global_history_bloc.dart';
import 'package:olivia/features/history/presentation/widgets/global_history_item_card.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/presentation/bloc/search_items_bloc.dart';
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
      appBar: AppBar(
        title: const Text('Riwayat'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Klaim Global'),
            Tab(text: 'Laporan Saya'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GlobalClaimHistoryView(),
          MyLostReportsView(),
        ],
      ),
    );
  }
}

// --- Widget untuk Tab Riwayat Klaim Global ---
class GlobalClaimHistoryView extends StatelessWidget {
  const GlobalClaimHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (Kode ini sudah benar dan tidak perlu diubah)
    return BlocProvider(
      create: (context) => sl<GlobalHistoryBloc>()..add(LoadGlobalHistory()),
      child: BlocBuilder<GlobalHistoryBloc, GlobalHistoryState>(
        builder: (context, state) {
          if (state is GlobalHistoryLoading) {
            return const Center(child: LoadingIndicator(message: 'Memuat riwayat...'));
          }
          if (state is GlobalHistoryFailure) {
            return Center(
              child: ErrorDisplayWidget(
                message: state.message,
                onRetry: () => context.read<GlobalHistoryBloc>().add(LoadGlobalHistory()),
              ),
            );
          }
          if (state is GlobalHistoryLoaded) {
            if (state.historyEntries.isEmpty) {
              return const Center(
                child: EmptyDataWidget(
                  message: 'Belum ada riwayat klaim barang.',
                  icon: Icons.history_rounded,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<GlobalHistoryBloc>().add(LoadGlobalHistory()),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.historyEntries.length,
                itemBuilder: (context, index) {
                  return GlobalHistoryItemCard(entry: state.historyEntries[index]);
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

// --- Widget untuk Tab Laporan Saya (DIPERBAIKI) ---
class MyLostReportsView extends StatelessWidget {
  const MyLostReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState.user?.id;

    if (currentUserId == null) {
      return const Center(child: Text('Login untuk melihat laporan Anda.'));
    }

    // PERBAIKAN: Tentukan filter reportType secara kaku berdasarkan peran pengguna
    final String reportTypeFilter;
    if (authState.user?.role == UserRole.keamanan) {
      // Keamanan HANYA melihat laporan penemuan yang mereka buat
      reportTypeFilter = 'penemuan';
    } else {
      // Pengguna biasa HANYA melihat laporan kehilangan yang mereka buat
      reportTypeFilter = 'kehilangan';
    }

    return BlocProvider(
      create: (context) => sl<SearchItemsBloc>()..add(
            LoadSearchFiltersAndPerformInitialSearch(
              // Kirim filter yang benar ke BLoC
              initialReportType: reportTypeFilter,
              initialReporterId: currentUserId,
            ),
          ),
      child: BlocBuilder<SearchItemsBloc, SearchItemsState>(
        builder: (context, state) {
          if (state.status == SearchStatus.loadingFilters || state.status == SearchStatus.loadingResults) {
            return const Center(child: LoadingIndicator(message: 'Memuat laporan...'));
          }
          
          if (state.status == SearchStatus.failure) {
            return Center(
              child: ErrorDisplayWidget(
                message: state.failure?.message ?? 'Gagal memuat laporan',
                onRetry: () => context.read<SearchItemsBloc>().add(
                  LoadSearchFiltersAndPerformInitialSearch(
                    initialReportType: reportTypeFilter,
                    initialReporterId: currentUserId,
                  ),
                ),
              ),
            );
          }
          
          if (state.status == SearchStatus.loaded) {
            if (state.items.isEmpty) {
              return const Center(
                child: EmptyDataWidget(
                  message: 'Anda belum memiliki laporan.',
                  icon: Icons.find_in_page_outlined,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<SearchItemsBloc>().add(
                LoadSearchFiltersAndPerformInitialSearch(
                  initialReportType: reportTypeFilter,
                  initialReporterId: currentUserId,
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  return ItemListCard(item: state.items[index]);
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
