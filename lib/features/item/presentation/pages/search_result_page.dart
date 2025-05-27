import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/home/domain/usecases/get_categories.dart'; // Untuk filter
import 'package:olivia/features/home/domain/usecases/get_locations.dart'; // Untuk filter
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/usecases/search_items.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/common_widgets/error_display_widget.dart';
import 'package:olivia/features/item/presentation/widgets/item_list_card.dart'; // Widget untuk menampilkan item

// BLoC untuk Search
class SearchItemsBloc extends Bloc<SearchEvent, SearchState> {
  final SearchItems _searchItemsUseCase;
  final GetCategories _getCategoriesUseCase;
  final GetLocations _getLocationsUseCase;

  SearchItemsBloc(
    this._searchItemsUseCase,
    this._getCategoriesUseCase,
    this._getLocationsUseCase,
  ) : super(SearchInitial()) {
    on<LoadSearchFilters>(_onLoadSearchFilters);
    on<PerformSearch>(_onPerformSearch);
    on<ApplyFilter>(_onApplyFilter); // Untuk saat filter diubah
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadSearchFilters(
    LoadSearchFilters event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoadingFilters());
    final categoriesResult = await _getCategoriesUseCase(NoParams());
    final locationsResult = await _getLocationsUseCase(NoParams());

    List<CategoryEntity> categories = [];
    List<LocationEntity> locations = [];

    categoriesResult.fold((l) => null, (r) => categories = r);
    locationsResult.fold((l) => null, (r) => locations = r);

    // Setelah filter dimuat, langsung jalankan pencarian awal jika ada query/filter awal
    if (state is SearchLoadingFilters || state is SearchInitial) {
      // Cek state sebelumnya
      add(
        PerformSearch(
          query: event.initialQuery,
          categoryId: event.initialCategoryId,
          locationId: event.initialLocationId,
          reportType: event.initialReportType,
          // Kirim filter yang sudah dimuat agar tidak hilang
          availableCategories: categories,
          availableLocations: locations,
          selectedCategory:
              categories
                  .where((c) => c.id == event.initialCategoryId)
                  .firstOrNull,
          selectedLocation:
              locations
                  .where((l) => l.id == event.initialLocationId)
                  .firstOrNull,
          selectedReportType: event.initialReportType,
        ),
      );
    }
  }

  Future<void> _onPerformSearch(
    PerformSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(
      SearchLoading(
        currentQuery: event.query ?? state.currentQuery,
        selectedCategory: event.selectedCategory ?? state.selectedCategory,
        selectedLocation: event.selectedLocation ?? state.selectedLocation,
        selectedReportType:
            event.selectedReportType ?? state.selectedReportType,
        availableCategories:
            event.availableCategories ?? state.availableCategories,
        availableLocations:
            event.availableLocations ?? state.availableLocations,
      ),
    );

    final result = await _searchItemsUseCase(
      SearchItemsParams(
        query: event.query ?? state.currentQuery,
        categoryId: (event.selectedCategory ?? state.selectedCategory)?.id,
        locationId: (event.selectedLocation ?? state.selectedLocation)?.id,
        reportType: event.selectedReportType ?? state.selectedReportType,
        // status bisa ditambahkan filter juga
      ),
    );

    result.fold(
      (failure) => emit(
        SearchFailure(
          failure.message,
          currentQuery: state.currentQuery,
          selectedCategory: state.selectedCategory,
          selectedLocation: state.selectedLocation,
          selectedReportType: state.selectedReportType,
          availableCategories: state.availableCategories,
          availableLocations: state.availableLocations,
        ),
      ),
      (items) => emit(
        SearchSuccess(
          items,
          currentQuery: state.currentQuery,
          selectedCategory: state.selectedCategory,
          selectedLocation: state.selectedLocation,
          selectedReportType: state.selectedReportType,
          availableCategories: state.availableCategories,
          availableLocations: state.availableLocations,
        ),
      ),
    );
  }

  void _onApplyFilter(ApplyFilter event, Emitter<SearchState> emit) {
    // Emit state loading dengan filter baru, lalu panggil PerformSearch
    emit(
      SearchLoading(
        currentQuery: event.query ?? state.currentQuery,
        selectedCategory:
            event.categoryId != null
                ? state.availableCategories.firstWhere(
                  (c) => c.id == event.categoryId,
                  orElse: () => state.selectedCategory!,
                )
                : state.selectedCategory,
        selectedLocation:
            event.locationId != null
                ? state.availableLocations.firstWhere(
                  (l) => l.id == event.locationId,
                  orElse: () => state.selectedLocation!,
                )
                : state.selectedLocation,
        selectedReportType: event.reportType ?? state.selectedReportType,
        availableCategories: state.availableCategories,
        availableLocations: state.availableLocations,
      ),
    );
    add(
      PerformSearch(
        query: event.query ?? state.currentQuery,
        selectedCategory:
            event.categoryId != null
                ? state.availableCategories.firstWhere(
                  (c) => c.id == event.categoryId,
                  orElse: () => state.selectedCategory!,
                )
                : state.selectedCategory,
        selectedLocation:
            event.locationId != null
                ? state.availableLocations.firstWhere(
                  (l) => l.id == event.locationId,
                  orElse: () => state.selectedLocation!,
                )
                : state.selectedLocation,
        reportType: event.reportType ?? state.selectedReportType,
        availableCategories: state.availableCategories,
        availableLocations: state.availableLocations,
      ),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(
      SearchSuccess(
        const [], // Kosongkan hasil
        currentQuery: '',
        selectedCategory: null,
        selectedLocation: null,
        selectedReportType: null,
        availableCategories: state.availableCategories,
        availableLocations: state.availableLocations,
      ),
    );
  }
}

// Event untuk Search
abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class LoadSearchFilters extends SearchEvent {
  final String? initialQuery;
  final String? initialCategoryId;
  final String? initialLocationId;
  final String? initialReportType;

  const LoadSearchFilters({
    this.initialQuery,
    this.initialCategoryId,
    this.initialLocationId,
    this.initialReportType,
  });
  @override
  List<Object?> get props => [
    initialQuery,
    initialCategoryId,
    initialLocationId,
    initialReportType,
  ];
}

class PerformSearch extends SearchEvent {
  final String? query;
  final CategoryEntity? selectedCategory; // Langsung objek
  final LocationEntity? selectedLocation; // Langsung objek
  final String? reportType; // 'kehilangan' atau 'penemuan'
  // Untuk menjaga data filter saat search
  final List<CategoryEntity>? availableCategories;
  final List<LocationEntity>? availableLocations;

  const PerformSearch({
    this.query,
    this.selectedCategory,
    this.selectedLocation,
    this.reportType,
    this.availableCategories,
    this.availableLocations,
  });
  @override
  List<Object?> get props => [
    query,
    selectedCategory,
    selectedLocation,
    reportType,
    availableCategories,
    availableLocations,
  ];
}

class ApplyFilter extends SearchEvent {
  final String? query; // Bisa juga dari text field search
  final String? categoryId;
  final String? locationId;
  final String? reportType;
  const ApplyFilter({
    this.query,
    this.categoryId,
    this.locationId,
    this.reportType,
  });
  @override
  List<Object?> get props => [query, categoryId, locationId, reportType];
}

class ClearSearch extends SearchEvent {}

// State untuk Search
abstract class SearchState extends Equatable {
  // Simpan filter aktif di state agar bisa diakses UI
  final String currentQuery;
  final CategoryEntity? selectedCategory;
  final LocationEntity? selectedLocation;
  final String? selectedReportType; // 'kehilangan' atau 'penemuan'
  final List<CategoryEntity> availableCategories;
  final List<LocationEntity> availableLocations;

  const SearchState({
    this.currentQuery = '',
    this.selectedCategory,
    this.selectedLocation,
    this.selectedReportType,
    this.availableCategories = const [],
    this.availableLocations = const [],
  });

  @override
  List<Object?> get props => [
    currentQuery,
    selectedCategory,
    selectedLocation,
    selectedReportType,
    availableCategories,
    availableLocations,
  ];
}

class SearchInitial extends SearchState {}

class SearchLoadingFilters
    extends
        SearchState {} // State saat memuat data kategori/lokasi untuk filter

class SearchLoading extends SearchState {
  const SearchLoading({
    super.currentQuery,
    super.selectedCategory,
    super.selectedLocation,
    super.selectedReportType,
    super.availableCategories,
    super.availableLocations,
  });
}

class SearchSuccess extends SearchState {
  final List<ItemEntity> items;
  const SearchSuccess(
    this.items, {
    super.currentQuery,
    super.selectedCategory,
    super.selectedLocation,
    super.selectedReportType,
    super.availableCategories,
    super.availableLocations,
  });
  @override
  List<Object?> get props => [items, ...super.props];
}

class SearchFailure extends SearchState {
  final String message;
  const SearchFailure(
    this.message, {
    super.currentQuery,
    super.selectedCategory,
    super.selectedLocation,
    super.selectedReportType,
    super.availableCategories,
    super.availableLocations,
  });
  @override
  List<Object?> get props => [message, ...super.props];
}

class SearchResultsPage extends StatefulWidget {
  final String? initialQuery;
  final String? categoryId; // dari home page
  final String? categoryName; // nama kategori untuk ditampilkan di filter awal
  final String? locationId; // dari home page
  final String? locationName; // nama lokasi
  final String? reportType; // dari home page 'kehilangan' atau 'penemuan'

  const SearchResultsPage({
    super.key,
    this.initialQuery,
    this.categoryId,
    this.categoryName,
    this.locationId,
    this.locationName,
    this.reportType,
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
    // Memuat filter dan melakukan pencarian awal
    _searchBloc.add(
      LoadSearchFilters(
        initialQuery: widget.initialQuery,
        initialCategoryId: widget.categoryId,
        initialLocationId: widget.locationId,
        initialReportType: widget.reportType,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    // _searchBloc.close(); // Tidak perlu jika menggunakan sl() factory
    super.dispose();
  }

  void _performSearch() {
    _searchBloc.add(PerformSearch(query: _searchController.text));
  }

  void _showFilterBottomSheet(BuildContext context, SearchState currentState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bisa full height jika perlu
      builder: (builderContext) {
        // Gunakan StatefulBuilder agar filter bisa diupdate di dalam bottom sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            CategoryEntity? tempSelectedCategory =
                currentState.selectedCategory;
            LocationEntity? tempSelectedLocation =
                currentState.selectedLocation;
            String? tempSelectedReportType = currentState.selectedReportType;

            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom, // Handle keyboard
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                // Jika konten filter banyak
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "Filter Pencarian",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),

                    // Filter Kategori
                    DropdownButtonFormField<CategoryEntity>(
                      value: tempSelectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Semua Kategori'),
                      items: [
                        const DropdownMenuItem<CategoryEntity>(
                          value: null,
                          child: Text('Semua Kategori'),
                        ),
                        ...currentState.availableCategories.map(
                          (c) =>
                              DropdownMenuItem(value: c, child: Text(c.name)),
                        ),
                      ],
                      onChanged:
                          (value) =>
                              setStateModal(() => tempSelectedCategory = value),
                    ),
                    const SizedBox(height: 16),

                    // Filter Lokasi
                    DropdownButtonFormField<LocationEntity>(
                      value: tempSelectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Semua Lokasi'),
                      items: [
                        const DropdownMenuItem<LocationEntity>(
                          value: null,
                          child: Text('Semua Lokasi'),
                        ),
                        ...currentState.availableLocations.map(
                          (l) =>
                              DropdownMenuItem(value: l, child: Text(l.name)),
                        ),
                      ],
                      onChanged:
                          (value) =>
                              setStateModal(() => tempSelectedLocation = value),
                    ),
                    const SizedBox(height: 16),

                    // Filter Jenis Laporan
                    DropdownButtonFormField<String>(
                      value: tempSelectedReportType,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Laporan',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Semua Jenis'),
                      items: const [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Semua Jenis'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'penemuan',
                          child: Text('Barang Ditemukan'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'kehilangan',
                          child: Text('Barang Hilang'),
                        ),
                      ],
                      onChanged:
                          (value) => setStateModal(
                            () => tempSelectedReportType = value,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      child: const Text("Terapkan Filter"),
                      onPressed: () {
                        _searchBloc.add(
                          ApplyFilter(
                            query:
                                _searchController
                                    .text, // Ambil query terbaru dari textfield
                            categoryId: tempSelectedCategory?.id,
                            locationId: tempSelectedLocation?.id,
                            reportType: tempSelectedReportType,
                          ),
                        );
                        Navigator.pop(context); // Tutup bottom sheet
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    TextButton(
                      child: const Text(
                        "Reset Filter",
                        style: TextStyle(color: AppColors.subtleTextColor),
                      ),
                      onPressed: () {
                        _searchBloc.add(
                          ApplyFilter(query: _searchController.text),
                        ); // Terapkan hanya dengan query
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
      // Gunakan .value karena instance sudah dibuat di initState
      value: _searchBloc,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            autofocus:
                widget.initialQuery == null, // Fokus jika tidak ada query awal
            decoration: InputDecoration(
              hintText: 'Cari nama barang, deskripsi...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(),
          ),
          actions: [
            BlocBuilder<SearchItemsBloc, SearchState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed:
                      (state is SearchLoadingFilters ||
                              state.availableCategories.isEmpty)
                          ? null
                          : () {
                            // Disable jika filter belum dimuat
                            _showFilterBottomSheet(context, state);
                          },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _performSearch,
            ),
          ],
        ),
        body: BlocBuilder<SearchItemsBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchInitial || state is SearchLoadingFilters) {
              return const Center(
                child: LoadingIndicator(message: 'Memuat filter...'),
              );
            }
            if (state is SearchLoading) {
              return const Center(
                child: LoadingIndicator(message: 'Mencari...'),
              );
            }
            if (state is SearchFailure) {
              return Center(
                child: ErrorDisplayWidget(
                  message: state.message,
                  onRetry: _performSearch,
                ),
              );
            }
            if (state is SearchSuccess) {
              if (state.items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      state.currentQuery.isEmpty &&
                              state.selectedCategory == null &&
                              state.selectedLocation == null &&
                              state.selectedReportType == null
                          ? 'Mulai pencarian atau pilih filter.'
                          : 'Tidak ada barang yang cocok dengan kriteria pencarian Anda.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.subtleTextColor,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  // Tampilkan filter aktif (opsional)
                  if (state.selectedCategory != null ||
                      state.selectedLocation != null ||
                      state.selectedReportType != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          if (state.selectedCategory != null)
                            Chip(
                              label: Text('K: ${state.selectedCategory!.name}'),
                              onDeleted: () {
                                _searchBloc.add(
                                  ApplyFilter(
                                    categoryId: '',
                                    reportType: state.selectedReportType,
                                    locationId: state.selectedLocation?.id,
                                    query: state.currentQuery,
                                  ),
                                );
                              },
                            ),
                          if (state.selectedLocation != null)
                            Chip(
                              label: Text('L: ${state.selectedLocation!.name}'),
                              onDeleted: () {
                                _searchBloc.add(
                                  ApplyFilter(
                                    locationId: '',
                                    reportType: state.selectedReportType,
                                    categoryId: state.selectedCategory?.id,
                                    query: state.currentQuery,
                                  ),
                                );
                              },
                            ),
                          if (state.selectedReportType != null)
                            Chip(
                              label: Text(
                                state.selectedReportType == 'penemuan'
                                    ? 'Ditemukan'
                                    : 'Hilang',
                              ),
                              onDeleted: () {
                                _searchBloc.add(
                                  ApplyFilter(
                                    reportType: '',
                                    categoryId: state.selectedCategory?.id,
                                    locationId: state.selectedLocation?.id,
                                    query: state.currentQuery,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        return ItemListCard(item: state.items[index]);
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink(); // Default
          },
        ),
      ),
    );
  }
}
