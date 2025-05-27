import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/home/domain/usecases/get_categories.dart'; // Untuk dropdown
import 'package:olivia/features/home/domain/usecases/get_locations.dart'; // Untuk dropdown
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/usecases/report_item.dart';

part 'report_item_event.dart';
part 'report_item_state.dart';

class ReportItemBloc extends Bloc<ReportItemEvent, ReportItemState> {
  final ReportItem _reportItemUseCase;
  final GetCategories
  _getCategoriesUseCase; // Inject use case untuk ambil kategori
  final GetLocations _getLocationsUseCase; // Inject use case untuk ambil lokasi

  ReportItemBloc({
    required ReportItem reportItemUseCase,
    required GetCategories getCategoriesUseCase,
    required GetLocations getLocationsUseCase,
  }) : _reportItemUseCase = reportItemUseCase,
       _getCategoriesUseCase = getCategoriesUseCase,
       _getLocationsUseCase = getLocationsUseCase,
       super(const ReportItemState()) {
    on<ReportItemTypeChanged>(_onReportItemTypeChanged);
    on<ReportItemNameChanged>(_onReportItemNameChanged);
    on<ReportItemDescriptionChanged>(_onReportItemDescriptionChanged);
    on<ReportItemCategoryChanged>(_onReportItemCategoryChanged);
    on<ReportItemLocationChanged>(_onReportItemLocationChanged);
    on<ReportItemImagePicked>(_onReportItemImagePicked);
    on<ReportItemSubmitted>(_onReportItemSubmitted);
    on<LoadCategoriesAndLocations>(_onLoadCategoriesAndLocations);

    // Load kategori dan lokasi saat BLoC diinisialisasi
    add(LoadCategoriesAndLocations());
  }

  void _onReportItemTypeChanged(
    ReportItemTypeChanged event,
    Emitter<ReportItemState> emit,
  ) {
    emit(state.copyWith(reportType: event.reportType, clearFailure: true));
  }

  void _onReportItemNameChanged(
    ReportItemNameChanged event,
    Emitter<ReportItemState> emit,
  ) {
    emit(state.copyWith(itemName: event.name, clearFailure: true));
  }

  void _onReportItemDescriptionChanged(
    ReportItemDescriptionChanged event,
    Emitter<ReportItemState> emit,
  ) {
    emit(state.copyWith(description: event.description, clearFailure: true));
  }

  void _onReportItemCategoryChanged(
    ReportItemCategoryChanged event,
    Emitter<ReportItemState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category, clearFailure: true));
  }

  void _onReportItemLocationChanged(
    ReportItemLocationChanged event,
    Emitter<ReportItemState> emit,
  ) {
    emit(state.copyWith(selectedLocation: event.location, clearFailure: true));
  }

  void _onReportItemImagePicked(
    ReportItemImagePicked event,
    Emitter<ReportItemState> emit,
  ) {
    emit(
      state.copyWith(
        imageFile: event.image,
        clearImageFile: event.image == null,
        clearFailure: true,
      ),
    );
  }

  Future<void> _onLoadCategoriesAndLocations(
    LoadCategoriesAndLocations event,
    Emitter<ReportItemState> emit,
  ) async {
    emit(state.copyWith(status: ReportItemStatus.loadingFormData));
    final categoriesResult = await _getCategoriesUseCase(NoParams());
    final locationsResult = await _getLocationsUseCase(NoParams());

    List<CategoryEntity> categories = [];
    List<LocationEntity> locations = [];
    Failure? loadingFailure;

    categoriesResult.fold(
      (failure) => loadingFailure = failure,
      (data) => categories = data,
    );

    locationsResult.fold(
      (failure) =>
          loadingFailure =
              failure, // Bisa menimpa error sebelumnya, handle jika perlu
      (data) => locations = data,
    );

    if (loadingFailure != null) {
      emit(
        state.copyWith(
          status: ReportItemStatus.failure,
          failure: loadingFailure,
          categories: categories, // Kirim data yang berhasil dimuat jika ada
          locations: locations,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status:
              ReportItemStatus
                  .initial, // Kembali ke initial setelah data dimuat
          categories: categories,
          locations: locations,
          clearFailure: true,
        ),
      );
    }
  }

  Future<void> _onReportItemSubmitted(
    ReportItemSubmitted event,
    Emitter<ReportItemState> emit,
  ) async {
    if (!state.isFormValid) {
      emit(
        state.copyWith(
          status: ReportItemStatus.failure,
          failure: InputValidationFailure(
            "Harap lengkapi semua field yang wajib diisi.",
          ),
        ),
      );
      return;
    }

    emit(state.copyWith(status: ReportItemStatus.loading, clearFailure: true));

    final params = ReportItemParams(
      reporterId: event.currentUserId,
      itemName: state.itemName,
      description: state.description.isNotEmpty ? state.description : null,
      categoryId: state.selectedCategory?.id,
      locationId: state.selectedLocation?.id,
      reportType: reportTypeToString(state.reportType),
      imageFile: state.imageFile,
      // latitude dan longitude bisa ditambahkan di sini jika ada inputnya
    );

    final result = await _reportItemUseCase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(status: ReportItemStatus.failure, failure: failure),
      ),
      (item) => emit(
        state.copyWith(status: ReportItemStatus.success, reportedItem: item),
      ),
    );
  }
}
