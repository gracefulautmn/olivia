part of 'report_item_bloc.dart';

abstract class ReportItemEvent extends Equatable {
  const ReportItemEvent();

  @override
  List<Object?> get props => [];
}

class ReportItemTypeChanged extends ReportItemEvent {
  final ReportType reportType;
  const ReportItemTypeChanged(this.reportType);
  @override
  List<Object?> get props => [reportType];
}

class ReportItemNameChanged extends ReportItemEvent {
  final String name;
  const ReportItemNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class ReportItemDescriptionChanged extends ReportItemEvent {
  final String description;
  const ReportItemDescriptionChanged(this.description);
  @override
  List<Object?> get props => [description];
}

class ReportItemCategoryChanged extends ReportItemEvent {
  final CategoryEntity? category;
  const ReportItemCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}

class ReportItemLocationChanged extends ReportItemEvent {
  final LocationEntity? location;
  const ReportItemLocationChanged(this.location);
  @override
  List<Object?> get props => [location];
}

class ReportItemImagePicked extends ReportItemEvent {
  final File? image;
  const ReportItemImagePicked(this.image);
  @override
  List<Object?> get props => [image];
}

// Event untuk memuat kategori dan lokasi untuk dropdown/pilihan
class LoadCategoriesAndLocations extends ReportItemEvent {}


class ReportItemSubmitted extends ReportItemEvent {
  final String currentUserId; // Diperlukan untuk reporterId
  const ReportItemSubmitted({required this.currentUserId});
   @override
  List<Object?> get props => [currentUserId];
}