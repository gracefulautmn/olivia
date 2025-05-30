import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/history/presentation/bloc/history_bloc.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/common_widgets/empty_data_widget.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
// import 'package:olivia/features/item/presentation/widgets/item_list_card.dart'; // Ganti ini
import 'package:olivia/features/history/presentation/widgets/history_item_card.dart'; // Gunakan ini

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  static const String routeName = '/history';

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HistoryBloc _historyBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _historyBloc = sl<HistoryBloc>();
    final authState = context.read<AuthBloc>().state;

    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      _historyBloc.add(LoadClaimedHistory(userId: authState.user!.id, asClaimer: true));
    }

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (authState.status == AuthStatus.authenticated && authState.user != null) {
          _historyBloc.add(LoadClaimedHistory(
            userId: authState.user!.id,
            asClaimer: _tabController.index == 0,
            refresh: true,
          ));
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState.status != AuthStatus.authenticated || authState.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Klaim')),
        body: const Center(child: Text('Anda harus login untuk melihat riwayat.')),
      );
    }

    return BlocProvider.value(
      value: _historyBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Barang'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Diklaim Saya'),
              Tab(text: 'Ditemukan Saya'),
            ],
          ),
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state.status == HistoryStatus.initial || state.status == HistoryStatus.loading) {
              return const Center(child: LoadingIndicator(message: 'Memuat riwayat...'));
            }
            if (state.status == HistoryStatus.failure) {
              return Center(
                child: ErrorDisplayWidget(
                  message: state.failure?.message ?? 'Gagal memuat riwayat.',
                  onRetry: () => _historyBloc.add(LoadClaimedHistory(
                    userId: authState.user!.id,
                    asClaimer: state.viewingAsClaimer,
                    refresh: true,
                  )),
                ),
              );
            }
            if (state.claimedItems.isEmpty) {
              return Center(
                child: EmptyDataWidget(
                  message: state.viewingAsClaimer
                      ? 'Anda belum pernah mengklaim barang.'
                      : 'Belum ada barang temuan Anda yang diklaim.',
                  icon: Icons.history_toggle_off_outlined,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                 _historyBloc.add(LoadClaimedHistory(
                    userId: authState.user!.id,
                    asClaimer: state.viewingAsClaimer,
                    refresh: true,
                  ));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.claimedItems.length,
                itemBuilder: (context, index) {
                  final item = state.claimedItems[index];
                  return HistoryItemCard( // Menggunakan HistoryItemCard
                    item: item,
                    isViewedByClaimer: state.viewingAsClaimer,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}