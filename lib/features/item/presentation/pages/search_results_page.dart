import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/item/presentation/bloc/search_items_bloc.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:olivia/common_widgets/empty_data_widget.dart';
import 'package:olivia/features/item/presentation/widgets/item_list_card.dart';

class SearchResultsPage extends StatefulWidget {
  final String? initialQuery;
  final String? categoryId;
  final String? locationId;
  // Hapus reportType dari constructor karena sekarang di-hardcode
  // final String? reportType;

  const SearchResultsPage({
    super.key,
    this.initialQuery,
    this.categoryId,
    this.locationId,
  });

  static const String routeName = '/search-results';

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final TextEditingController _searchController = TextEditingController();
  late SearchItemsBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = sl<SearchItemsBloc>();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    _searchBloc.add(LoadSearchFiltersAndPerformInitialSearch(
      initialQuery: widget.initialQuery,
      initialCategoryId: widget.categoryId,
      initialLocationId: widget.locationId,
      // PERBAIKAN: Selalu set reportType ke 'penemuan'
      initialReportType: 'penemuan',
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearchFromTextField() {
    // PerformSearchQuery akan menggunakan filter yang sudah ada di state,
    // yang sudah kita set ke 'penemuan'.
    _searchBloc.add(PerformSearchQuery(query: _searchController.text));
  }

  void _showFilterBottomSheet(BuildContext context, SearchItemsState currentState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (builderContext) {
        CategoryEntity? tempSelectedCategory = currentState.selectedCategory;
        LocationEntity? tempSelectedLocation = currentState.selectedLocation;
        // String? tempSelectedReportType tidak lagi diperlukan

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20, right: 20, top: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text("Filter Pencarian", style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<CategoryEntity?>(
                      value: tempSelectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                      hint: const Text('Semua Kategori'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<CategoryEntity?>(value: null, child: Text('Semua Kategori')),
                        ...currentState.availableCategories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))),
                      ],
                      onChanged: (value) => setStateModal(() => tempSelectedCategory = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LocationEntity?>(
                      value: tempSelectedLocation,
                      decoration: const InputDecoration(labelText: 'Lokasi', border: OutlineInputBorder()),
                      hint: const Text('Semua Lokasi'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<LocationEntity?>(value: null, child: Text('Semua Lokasi')),
                        ...currentState.availableLocations.map((l) => DropdownMenuItem(value: l, child: Text(l.name))),
                      ],
                      onChanged: (value) => setStateModal(() => tempSelectedLocation = value),
                    ),
                    const SizedBox(height: 16),
                    
                    // PERBAIKAN: Menghapus DropdownButtonFormField untuk Jenis Laporan

                    const SizedBox(height: 24),
                    ElevatedButton(
                      child: const Text("Terapkan Filter"),
                      onPressed: () {
                        _searchBloc.add(ApplySearchFilters(
                          categoryIdToSet: tempSelectedCategory?.id,
                          locationIdToSet: tempSelectedLocation?.id,
                          // Tidak perlu mengirim reportType, BLoC akan tetap menggunakan 'penemuan'
                        ));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                    TextButton(
                      child: const Text("Reset Filter", style: TextStyle(color: Colors.grey)),
                      onPressed: (){
                          _searchBloc.add(const ApplySearchFilters(categoryIdToSet: null, locationIdToSet: null));
                          Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            autofocus: widget.initialQuery == null && widget.categoryId == null && widget.locationId == null,
            decoration: InputDecoration(
              hintText: 'Cari barang temuan...', // Teks diubah
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _triggerSearchFromTextField(),
          ),
          actions: [
            BlocBuilder<SearchItemsBloc, SearchItemsState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter',
                  onPressed: (state.status == SearchStatus.loadingFilters || state.availableCategories.isEmpty)
                      ? null // Disable jika filter belum dimuat
                      : () => _showFilterBottomSheet(context, state),
                );
              }
            ),
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Cari',
              onPressed: _triggerSearchFromTextField,
            ),
          ],
        ),
        body: Column(
          children: [
            BlocBuilder<SearchItemsBloc, SearchItemsState>(
              builder: (context, state) {
                if (state.selectedCategory == null && state.selectedLocation == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 0.0,
                    children: [
                      if (state.selectedCategory != null)
                        Chip(
                          label: Text('K: ${state.selectedCategory!.name}'),
                          onDeleted: () => _searchBloc.add(const ApplySearchFilters(categoryIdToSet: null)),
                          deleteIconColor: AppColors.primaryColor.withOpacity(0.7),
                        ),
                      if (state.selectedLocation != null)
                        Chip(
                          label: Text('L: ${state.selectedLocation!.name}'),
                          onDeleted: () => _searchBloc.add(const ApplySearchFilters(locationIdToSet: null)),
                          deleteIconColor: AppColors.primaryColor.withOpacity(0.7),
                        ),
                      
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<SearchItemsBloc, SearchItemsState>(
                builder: (context, state) {
                  if (state.status == SearchStatus.initial || state.status == SearchStatus.loadingFilters) {
                    return const Center(child: LoadingIndicator(message: 'Memuat...'));
                  }
                  if (state.status == SearchStatus.loadingResults) {
                    if (state.items.isEmpty) {
                      return const Center(child: LoadingIndicator(message: 'Mencari...'));
                    }
                  }
                  if (state.status == SearchStatus.failure) {
                    return Center(child: ErrorDisplayWidget(
                      message: state.failure?.message ?? 'Gagal melakukan pencarian.',
                      onRetry: _triggerSearchFromTextField,
                    ));
                  }
                  if (state.status == SearchStatus.loaded || state.status == SearchStatus.loadingResults) {
                     if (state.items.isEmpty) {
                      return const EmptyDataWidget(message: 'Tidak ada barang temuan yang cocok dengan kriteria pencarian Anda.', icon: Icons.sentiment_dissatisfied_outlined);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        return ItemListCard(item: state.items[index]);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
