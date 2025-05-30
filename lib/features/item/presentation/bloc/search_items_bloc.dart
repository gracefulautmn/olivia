import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/core/usecases/usecase.dart'; // Pastikan path benar
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/home/domain/usecases/get_categories.dart';
import 'package:olivia/features/home/domain/usecases/get_locations.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/usecases/search_items.dart';
import 'package:olivia/core/errors/failures.dart'; // Pastikan path benar
import 'package:collection/collection.dart'; // Untuk firstWhereOrNull

part 'search_items_event.dart';
part 'search_items_state.dart';

class SearchItemsBloc extends Bloc<SearchItemsEvent, SearchItemsState> {
  final SearchItems _searchItemsUseCase;
  final GetCategories _getCategoriesUseCase;
  final GetLocations _getLocationsUseCase;

  SearchItemsBloc({
    required SearchItems searchItemsUseCase,
    required GetCategories getCategoriesUseCase,
    required GetLocations getLocationsUseCase,
  })  : _searchItemsUseCase = searchItemsUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        _getLocationsUseCase = getLocationsUseCase,
        super(SearchInitial()) {
    on<LoadSearchFiltersAndPerformInitialSearch>(_onLoadSearchFiltersAndPerformInitialSearch);
    on<PerformSearchQuery>(_onPerformSearchQuery);
    on<ApplySearchFilters>(_onApplySearchFilters);
    on<ClearAllSearchAndFilters>(_onClearAllSearchAndFilters);
  }

  Future<void> _onLoadSearchFiltersAndPerformInitialSearch(
    LoadSearchFiltersAndPerformInitialSearch event,
    Emitter<SearchItemsState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.loadingFilters));
    final categoriesResult = await _getCategoriesUseCase(NoParams());
    final locationsResult = await _getLocationsUseCase(NoParams());

    List<CategoryEntity> categories = [];
    List<LocationEntity> locations = [];
    Failure? loadingFailure;

    categoriesResult.fold((failure) => loadingFailure = failure, (data) => categories = data);
    if (loadingFailure != null) {
      emit(state.copyWith(status: SearchStatus.failure, failure: loadingFailure));
      return;
    }
    locationsResult.fold((failure) => loadingFailure = failure, (data) => locations = data);
    if (loadingFailure != null) {
      emit(state.copyWith(status: SearchStatus.failure, failure: loadingFailure, availableCategories: categories));
      return;
    }
    
    // Set filter awal dari event
    final initialSelectedCategory = categories.firstWhereOrNull((c) => c.id == event.initialCategoryId);
    final initialSelectedLocation = locations.firstWhereOrNull((l) => l.id == event.initialLocationId);

    // Langsung lakukan pencarian awal
    add(PerformSearchQuery(
      query: event.initialQuery,
      selectedCategory: initialSelectedCategory,
      selectedLocation: initialSelectedLocation,
      selectedReportType: event.initialReportType,
      // Penting untuk meneruskan availableCategories dan availableLocations
      // agar tidak hilang saat PerformSearchQuery dijalankan.
      availableCategories: categories,
      availableLocations: locations,
    ));
  }
  
  Future<void> _onPerformSearchQuery(PerformSearchQuery event, Emitter<SearchItemsState> emit) async {
    // Ambil filter dari event jika ada, jika tidak dari state
    // Ini penting karena _onLoadSearchFiltersAndPerformInitialSearch mengirim filter lengkap di event PerformSearchQuery
    final queryToUse = event.query ?? state.currentQuery;
    final categoryToUse = event.selectedCategory ?? state.selectedCategory;
    final locationToUse = event.selectedLocation ?? state.selectedLocation;
    final reportTypeToUse = event.selectedReportType ?? state.selectedReportType;
    // Pastikan available filters juga diteruskan
    final availableCategoriesToUse = event.availableCategories ?? state.availableCategories;
    final availableLocationsToUse = event.availableLocations ?? state.availableLocations;

    emit(state.copyWith(
      status: SearchStatus.loadingResults,
      currentQuery: queryToUse,
      selectedCategory: categoryToUse,
      selectedLocation: locationToUse,
      selectedReportType: reportTypeToUse,
      availableCategories: availableCategoriesToUse, // Pastikan ini terisi
      availableLocations: availableLocationsToUse, // Pastikan ini terisi
      clearFailure: true,
    ));

    final result = await _searchItemsUseCase(SearchItemsParams(
      query: queryToUse,
      categoryId: categoryToUse?.id,
      locationId: locationToUse?.id,
      reportType: reportTypeToUse,
    ));

    result.fold(
      (failure) => emit(state.copyWith(status: SearchStatus.failure, failure: failure)),
      (items) => emit(state.copyWith(
        status: SearchStatus.loaded,
        items: items,
        // Filter tetap sama seperti saat query dimulai
      )),
    );
  }

  void _onApplySearchFilters(ApplySearchFilters event, Emitter<SearchItemsState> emit) {
    // Saat filter diubah, panggil PerformSearchQuery dengan filter baru
    // Pastikan state.availableCategories dan state.availableLocations sudah terisi dari LoadSearchFilters
    final newSelectedCategory = event.categoryIdToSet != null
        ? state.availableCategories.firstWhereOrNull((c) => c.id == event.categoryIdToSet)
        : null; // Jika categoryIdToSet null, berarti menghapus filter kategori

    final newSelectedLocation = event.locationIdToSet != null
        ? state.availableLocations.firstWhereOrNull((l) => l.id == event.locationIdToSet)
        : null; // Jika locationIdToSet null, berarti menghapus filter lokasi
    
    final newReportType = event.reportTypeToSet; // Bisa null untuk menghapus filter

    add(PerformSearchQuery(
      query: state.currentQuery, // Query saat ini tidak berubah oleh filter
      selectedCategory: newSelectedCategory,
      selectedLocation: newSelectedLocation,
      selectedReportType: newReportType,
      availableCategories: state.availableCategories,
      availableLocations: state.availableLocations,
    ));
  }

  void _onClearAllSearchAndFilters(ClearAllSearchAndFilters event, Emitter<SearchItemsState> emit) {
    emit(state.copyWith(
      status: SearchStatus.loaded, // Atau initial jika ingin reset sepenuhnya
      items: [],
      currentQuery: '',
      selectedCategory: null,
      selectedLocation: null,
      selectedReportType: null,
      // availableCategories dan availableLocations tetap ada untuk filter berikutnya
    ));
  }
}