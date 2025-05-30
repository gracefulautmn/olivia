part of 'search_items_bloc.dart';

abstract class SearchItemsEvent extends Equatable {
  const SearchItemsEvent();
  @override
  List<Object?> get props => [];
}

// Event untuk memuat filter (kategori, lokasi) dan melakukan pencarian awal
class LoadSearchFiltersAndPerformInitialSearch extends SearchItemsEvent {
  final String? initialQuery;
  final String? initialCategoryId;   // ID
  final String? initialLocationId;   // ID
  final String? initialReportType; // 'kehilangan' atau 'penemuan'

  const LoadSearchFiltersAndPerformInitialSearch({
    this.initialQuery,
    this.initialCategoryId,
    this.initialLocationId,
    this.initialReportType,
  });

  @override
  List<Object?> get props => [initialQuery, initialCategoryId, initialLocationId, initialReportType];
}

// Event untuk melakukan pencarian berdasarkan query dan filter yang sudah ada di state atau dari event ini
class PerformSearchQuery extends SearchItemsEvent {
  final String? query;
  // Filter yang mungkin di-override saat pencarian
  final CategoryEntity? selectedCategory;
  final LocationEntity? selectedLocation;
  final String? selectedReportType;
  // Ini penting untuk memastikan BLoC memiliki data filter saat memanggil use case
  final List<CategoryEntity>? availableCategories;
  final List<LocationEntity>? availableLocations;


  const PerformSearchQuery({
    this.query,
    this.selectedCategory,
    this.selectedLocation,
    this.selectedReportType,
    this.availableCategories, // Diteruskan dari LoadSearchFilters
    this.availableLocations,  // Diteruskan dari LoadSearchFilters
  });

  @override
  List<Object?> get props => [query, selectedCategory, selectedLocation, selectedReportType, availableCategories, availableLocations];
}

// Event untuk menerapkan filter baru dari UI (misal, bottom sheet filter)
class ApplySearchFilters extends SearchItemsEvent {
  // ID kategori/lokasi yang dipilih, atau null untuk menghapus filter
  final String? categoryIdToSet;
  final String? locationIdToSet;
  final String? reportTypeToSet; // 'kehilangan', 'penemuan', atau null untuk semua/hapus

  const ApplySearchFilters({
    this.categoryIdToSet,
    this.locationIdToSet,
    this.reportTypeToSet,
  });

  @override
  List<Object?> get props => [categoryIdToSet, locationIdToSet, reportTypeToSet];
}

// Event untuk menghapus semua query dan filter
class ClearAllSearchAndFilters extends SearchItemsEvent {}