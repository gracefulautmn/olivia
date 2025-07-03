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

  // --- PENAMBAHAN UNTUK MODE EDIT ---
  final String? initialImageUrl; // Untuk menampilkan gambar lama saat edit

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
    this.initialImageUrl, // Tambahkan di konstruktor
  });

  ReportItemState copyWith({
    ReportItemStatus? status,
    ReportType? reportType,
    String? itemName,
    String? description,
    CategoryEntity? selectedCategory,
    bool clearSelectedCategory = false,
    LocationEntity? selectedLocation,
    bool clearSelectedLocation = false,
    File? imageFile,
    bool clearImageFile = false,
    Failure? failure,
    bool clearFailure = false,
    ItemEntity? reportedItem,
    List<CategoryEntity>? categories,
    List<LocationEntity>? locations,
    String? initialImageUrl, // Tambahkan di copyWith
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
      initialImageUrl: initialImageUrl ?? this.initialImageUrl, // Tambahkan di copyWith
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
        initialImageUrl, // Tambahkan ke props
      ];

  bool get isFormValid => itemName.isNotEmpty && (selectedCategory != null || reportType == ReportType.kehilangan) && (selectedLocation != null);
}
