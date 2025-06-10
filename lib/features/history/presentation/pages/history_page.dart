import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/history/presentation/bloc/global_history_bloc.dart'; // BLoC baru
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/common_widgets/empty_data_widget.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:olivia/features/history/presentation/widgets/global_history_item_card.dart'; // Widget card baru

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const String routeName = '/history';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<GlobalHistoryBloc>()..add(LoadGlobalHistory()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Klaim Barang'),
        ),
        body: BlocBuilder<GlobalHistoryBloc, GlobalHistoryState>(
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
                    message: 'Belum ada barang yang diklaim.',
                    icon: Icons.history_toggle_off_outlined,
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<GlobalHistoryBloc>().add(LoadGlobalHistory());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: state.historyEntries.length,
                  itemBuilder: (context, index) {
                    final entry = state.historyEntries[index];
                    return GlobalHistoryItemCard(entry: entry);
                  },
                ),
              );
            }
            return const SizedBox.shrink(); // Untuk state initial
          },
        ),
      ),
    );
  }
}
