part of 'search_items_bloc.dart';

enum SearchStatus { initial, loadingFilters, loadingResults, loaded, failure }

class SearchItemsState extends Equatable {
  final SearchStatus status;
  final List<ItemEntity> items;
  final Failure? failure;

  // Filter aktif
  final String currentQuery;
  final CategoryEntity? selectedCategory;
  final LocationEntity? selectedLocation;
  final String? selectedReportType; // 'kehilangan' atau 'penemuan'

  // Data untuk dropdown filter
  final List<CategoryEntity> availableCategories;
  final List<LocationEntity> availableLocations;

  const SearchItemsState({
    this.status = SearchStatus.initial,
    this.items = const [],
    this.failure,
    this.currentQuery = '',
    this.selectedCategory,
    this.selectedLocation,
    this.selectedReportType,
    this.availableCategories = const [],
    this.availableLocations = const [],
  });

  SearchItemsState copyWith({
    SearchStatus? status,
    List<ItemEntity>? items,
    Failure? failure,
    String? currentQuery,
    CategoryEntity? selectedCategory, // Bisa null untuk clear
    LocationEntity? selectedLocation, // Bisa null untuk clear
    String? selectedReportType,      // Bisa null untuk clear
    List<CategoryEntity>? availableCategories,
    List<LocationEntity>? availableLocations,
    bool clearFailure = false,
    bool clearSelectedCategory = false, // Helper untuk menghapus
    bool clearSelectedLocation = false,
    bool clearSelectedReportType = false,
  }) {
    return SearchItemsState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: clearFailure ? null : failure ?? this.failure,
      currentQuery: currentQuery ?? this.currentQuery,
      selectedCategory: clearSelectedCategory ? null : selectedCategory ?? this.selectedCategory,
      selectedLocation: clearSelectedLocation ? null : selectedLocation ?? this.selectedLocation,
      selectedReportType: clearSelectedReportType ? null : selectedReportType ?? this.selectedReportType,
      availableCategories: availableCategories ?? this.availableCategories,
      availableLocations: availableLocations ?? this.availableLocations,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        failure,
        currentQuery,
        selectedCategory,
        selectedLocation,
        selectedReportType,
        availableCategories,
        availableLocations,
      ];
}

// Sub-state untuk lebih spesifik jika diperlukan (opsional)
class SearchInitial extends SearchItemsState {}
// Tidak perlu lagi SearchLoadingFilters, SearchLoading, SearchSuccess, SearchFailure
// karena SearchStatus di state utama sudah mencakupnya.