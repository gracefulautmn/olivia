import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/usecases/search_items.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:collection/collection.dart';
import 'package:olivia/features/home/domain/usecases/get_categories.dart';
import 'package:olivia/features/home/domain/usecases/get_locations.dart';

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
    
    final initialSelectedCategory = categories.firstWhereOrNull((c) => c.id == event.initialCategoryId);
    final initialSelectedLocation = locations.firstWhereOrNull((l) => l.id == event.initialLocationId);

    add(PerformSearchQuery(
      query: event.initialQuery,
      selectedCategory: initialSelectedCategory,
      selectedLocation: initialSelectedLocation,
      selectedReportType: event.initialReportType,
      reporterId: event.initialReporterId,
      availableCategories: categories,
      availableLocations: locations,
    ));
  }
  
  Future<void> _onPerformSearchQuery(PerformSearchQuery event, Emitter<SearchItemsState> emit) async {
    final queryToUse = event.query ?? state.currentQuery;
    final categoryToUse = event.selectedCategory ?? state.selectedCategory;
    final locationToUse = event.selectedLocation ?? state.selectedLocation;
    final reportTypeToUse = event.selectedReportType ?? state.selectedReportType;
    final reporterIdToUse = event.reporterId ?? state.reporterId;
    final availableCategoriesToUse = event.availableCategories ?? state.availableCategories;
    final availableLocationsToUse = event.availableLocations ?? state.availableLocations;

    emit(state.copyWith(
      status: SearchStatus.loadingResults,
      currentQuery: queryToUse,
      selectedCategory: categoryToUse,
      selectedLocation: locationToUse,
      selectedReportType: reportTypeToUse,
      reporterId: reporterIdToUse,
      availableCategories: availableCategoriesToUse,
      availableLocations: availableLocationsToUse,
      clearFailure: true,
    ));

    // PENTING: Pastikan SearchItemsParams Anda juga memiliki parameter `reporterId`
    final result = await _searchItemsUseCase(SearchItemsParams(
      query: queryToUse,
      categoryId: categoryToUse?.id,
      locationId: locationToUse?.id,
      reportType: reportTypeToUse,
      reporterId: reporterIdToUse,
      status: reportTypeToUse == 'penemuan' ? 'ditemukan_tersedia' : null,
    ));

    result.fold(
      (failure) => emit(state.copyWith(status: SearchStatus.failure, failure: failure)),
      (items) => emit(state.copyWith(status: SearchStatus.loaded, items: items)),
    );
  }

  void _onApplySearchFilters(ApplySearchFilters event, Emitter<SearchItemsState> emit) {
    final newSelectedCategory = event.categoryIdToSet != null
        ? state.availableCategories.firstWhereOrNull((c) => c.id == event.categoryIdToSet)
        : null;

    final newSelectedLocation = event.locationIdToSet != null
        ? state.availableLocations.firstWhereOrNull((l) => l.id == event.locationIdToSet)
        : null;
    
    final newReportType = event.reportTypeToSet;

    add(PerformSearchQuery(
      query: state.currentQuery,
      selectedCategory: newSelectedCategory,
      selectedLocation: newSelectedLocation,
      selectedReportType: newReportType,
      reporterId: state.reporterId, // Tetap gunakan reporterId dari state jika ada
      availableCategories: state.availableCategories,
      availableLocations: state.availableLocations,
    ));
  }

  void _onClearAllSearchAndFilters(ClearAllSearchAndFilters event, Emitter<SearchItemsState> emit) {
    emit(state.copyWith(
      status: SearchStatus.loaded,
      items: [],
      currentQuery: '',
      selectedCategory: null,
      selectedLocation: null,
      selectedReportType: null,
      reporterId: null, // Hapus juga filter reporterId
      clearFailure: true,
    ));
  }
}
