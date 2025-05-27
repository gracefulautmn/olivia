part of 'report_item_bloc.dart';

enum ReportItemStatus { initial, loading, success, failure, loadingFormData }

class ReportItemState extends Equatable {
  final ReportItemStatus status;
  final ReportType reportType;
  final String itemName;
  final String description;
  final CategoryEntity? selectedCategory;
  final LocationEntity? selectedLocation;
  final File? imageFile;
  final Failure? failure;
  final ItemEntity? reportedItem; // Untuk feedback setelah sukses

  // Data untuk dropdown/pilihan
  final List<CategoryEntity> categories;
  final List<LocationEntity> locations;


  const ReportItemState({
    this.status = ReportItemStatus.initial,
    this.reportType = ReportType.kehilangan, // Default
    this.itemName = '',
    this.description = '',
    this.selectedCategory,
    this.selectedLocation,
    this.imageFile,
    this.failure,
    this.reportedItem,
    this.categories = const [],
    this.locations = const [],
  });

  ReportItemState copyWith({
    ReportItemStatus? status,
    ReportType? reportType,
    String? itemName,
    String? description,
    CategoryEntity? selectedCategory,
    bool clearSelectedCategory = false, // Untuk menghapus pilihan
    LocationEntity? selectedLocation,
    bool clearSelectedLocation = false, // Untuk menghapus pilihan
    File? imageFile,
    bool clearImageFile = false, // Untuk menghapus pilihan
    Failure? failure,
    bool clearFailure = false,
    ItemEntity? reportedItem,
    List<CategoryEntity>? categories,
    List<LocationEntity>? locations,
  }) {
    return ReportItemState(
      status: status ?? this.status,
      reportType: reportType ?? this.reportType,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      selectedCategory: clearSelectedCategory ? null : selectedCategory ?? this.selectedCategory,
      selectedLocation: clearSelectedLocation ? null : selectedLocation ?? this.selectedLocation,
      imageFile: clearImageFile ? null : imageFile ?? this.imageFile,
      failure: clearFailure ? null : failure ?? this.failure,
      reportedItem: reportedItem ?? this.reportedItem,
      categories: categories ?? this.categories,
      locations: locations ?? this.locations,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reportType,
        itemName,
        description,
        selectedCategory,
        selectedLocation,
        imageFile,
        failure,
        reportedItem,
        categories,
        locations,
      ];

  // Helper untuk validasi form sederhana
  bool get isFormValid => itemName.isNotEmpty && (selectedCategory != null || reportType == ReportType.kehilangan) && (selectedLocation != null || reportType == ReportType.kehilangan) ;
}