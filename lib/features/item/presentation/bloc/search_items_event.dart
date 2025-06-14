part of 'search_items_bloc.dart';

abstract class SearchItemsEvent extends Equatable {
  const SearchItemsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSearchFiltersAndPerformInitialSearch extends SearchItemsEvent {
  final String? initialQuery;
  final String? initialCategoryId;
  final String? initialLocationId;
  final String? initialReportType;
  // PERBAIKAN: Tambahkan initialReporterId
  final String? initialReporterId;

  const LoadSearchFiltersAndPerformInitialSearch({
    this.initialQuery,
    this.initialCategoryId,
    this.initialLocationId,
    this.initialReportType,
    this.initialReporterId, // Tambahkan di konstruktor
  });
}

class PerformSearchQuery extends SearchItemsEvent {
  final String? query;
  final CategoryEntity? selectedCategory;
  final LocationEntity? selectedLocation;
  final String? selectedReportType;
  final String? reporterId; // Tambahkan reporterId
  // Diperlukan untuk meneruskan filter yang sudah ada saat hanya query yang berubah
  final List<CategoryEntity>? availableCategories;
  final List<LocationEntity>? availableLocations;

  const PerformSearchQuery({
    this.query,
    this.selectedCategory,
    this.selectedLocation,
    this.selectedReportType,
    this.reporterId, // Tambahkan di konstruktor
    this.availableCategories,
    this.availableLocations,
  });
}

// Event ApplySearchFilters dan ClearAllSearchAndFilters tetap sama

class ApplySearchFilters extends SearchItemsEvent {
  final String? categoryIdToSet;
  final String? locationIdToSet;
  final String? reportTypeToSet;

  const ApplySearchFilters({
    this.categoryIdToSet,
    this.locationIdToSet,
    this.reportTypeToSet,
  });
}

class ClearAllSearchAndFilters extends SearchItemsEvent {
  const ClearAllSearchAndFilters();
}

