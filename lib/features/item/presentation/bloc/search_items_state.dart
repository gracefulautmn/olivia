part of 'search_items_bloc.dart';

enum SearchStatus { initial, loadingFilters, loadingResults, loaded, failure }

class SearchItemsState extends Equatable {
  final SearchStatus status;
  final List<ItemEntity> items;
  final List<CategoryEntity> availableCategories;
  final List<LocationEntity> availableLocations;
  final String currentQuery;
  final CategoryEntity? selectedCategory;
  final LocationEntity? selectedLocation;
  final String? selectedReportType;
  final Failure? failure;
  // PERBAIKAN: Tambahkan reporterId untuk melacak filter pengguna
  final String? reporterId;

  const SearchItemsState({
    this.status = SearchStatus.initial,
    this.items = const [],
    this.availableCategories = const [],
    this.availableLocations = const [],
    this.currentQuery = '',
    this.selectedCategory,
    this.selectedLocation,
    this.selectedReportType,
    this.failure,
    this.reporterId, // Tambahkan di konstruktor
  });

  SearchItemsState copyWith({
    SearchStatus? status,
    List<ItemEntity>? items,
    List<CategoryEntity>? availableCategories,
    List<LocationEntity>? availableLocations,
    String? currentQuery,
    CategoryEntity? selectedCategory,
    LocationEntity? selectedLocation,
    String? selectedReportType,
    Failure? failure,
    String? reporterId, // Tambahkan di copyWith
    bool clearFailure = false,
  }) {
    return SearchItemsState(
      status: status ?? this.status,
      items: items ?? this.items,
      availableCategories: availableCategories ?? this.availableCategories,
      availableLocations: availableLocations ?? this.availableLocations,
      currentQuery: currentQuery ?? this.currentQuery,
      selectedCategory: selectedCategory,
      selectedLocation: selectedLocation,
      selectedReportType: selectedReportType,
      failure: clearFailure ? null : failure ?? this.failure,
      reporterId: reporterId, // Tambahkan di copyWith
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        availableCategories,
        availableLocations,
        currentQuery,
        selectedCategory,
        selectedLocation,
        selectedReportType,
        failure,
        reporterId, // Tambahkan di props
      ];
}

class SearchInitial extends SearchItemsState {}
