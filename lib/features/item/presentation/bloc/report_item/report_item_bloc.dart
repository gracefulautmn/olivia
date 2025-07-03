import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/home/domain/usecases/get_categories.dart';
import 'package:olivia/features/home/domain/usecases/get_locations.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/usecases/report_item.dart';
import 'package:olivia/features/item/domain/usecases/update_item.dart'; // <-- IMPORT BARU

part 'report_item_event.dart';
part 'report_item_state.dart';

class ReportItemBloc extends Bloc<ReportItemEvent, ReportItemState> {
  final ReportItem _reportItemUseCase;
  final UpdateItem _updateItemUseCase; // <-- DEPENDENSI BARU
  final GetCategories _getCategoriesUseCase;
  final GetLocations _getLocationsUseCase;

  ReportItemBloc({
    required ReportItem reportItemUseCase,
    required UpdateItem updateItemUseCase, // <-- DEPENDENSI BARU
    required GetCategories getCategoriesUseCase,
    required GetLocations getLocationsUseCase,
  })  : _reportItemUseCase = reportItemUseCase,
        _updateItemUseCase = updateItemUseCase, // <-- DEPENDENSI BARU
        _getCategoriesUseCase = getCategoriesUseCase,
        _getLocationsUseCase = getLocationsUseCase,
        super(const ReportItemState()) {
    
    on<InitializeForEdit>(_onInitializeForEdit); // <-- HANDLER BARU
    on<UpdateItemSubmitted>(_onUpdateItemSubmitted); // <-- HANDLER BARU
    
    on<ReportItemTypeChanged>(_onReportItemTypeChanged);
    on<ReportItemNameChanged>(_onReportItemNameChanged);
    on<ReportItemDescriptionChanged>(_onReportItemDescriptionChanged);
    on<ReportItemCategoryChanged>(_onReportItemCategoryChanged);
    on<ReportItemLocationChanged>(_onReportItemLocationChanged);
    on<ReportItemImagePicked>(_onReportItemImagePicked);
    on<ReportItemSubmitted>(_onReportItemSubmitted);
    on<LoadCategoriesAndLocations>(_onLoadCategoriesAndLocations);

    add(LoadCategoriesAndLocations());
  }

  // --- HANDLER BARU UNTUK MENGISI FORM SAAT EDIT ---
  void _onInitializeForEdit(
    InitializeForEdit event,
    Emitter<ReportItemState> emit,
  ) {
    emit(state.copyWith(
      status: ReportItemStatus.initial,
      itemName: event.itemToEdit.itemName,
      description: event.itemToEdit.description ?? '',
      reportType: event.itemToEdit.reportType,
      selectedCategory: event.itemToEdit.category,
      selectedLocation: event.itemToEdit.location,
      initialImageUrl: event.itemToEdit.imageUrl,
    ));
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
      (failure) => loadingFailure = failure,
      (data) => locations = data,
    );

    if (loadingFailure != null) {
      emit(
        state.copyWith(
          status: ReportItemStatus.failure,
          failure: loadingFailure,
          categories: categories,
          locations: locations,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: ReportItemStatus.initial,
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
    // Validasi form dipindahkan ke UI untuk feedback yang lebih cepat
    emit(state.copyWith(status: ReportItemStatus.loading, clearFailure: true));

    final params = ReportItemParams(
      reporterId: event.currentUserId,
      itemName: state.itemName,
      description: state.description.isNotEmpty ? state.description : null,
      categoryId: state.selectedCategory?.id,
      locationId: state.selectedLocation!.id, // Diasumsikan tidak null karena sudah divalidasi
      reportType: reportTypeToString(state.reportType),
      imageFile: state.imageFile,
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

  // --- HANDLER BARU UNTUK MENYIMPAN PERUBAHAN ---
  Future<void> _onUpdateItemSubmitted(
    UpdateItemSubmitted event,
    Emitter<ReportItemState> emit,
  ) async {
    emit(state.copyWith(status: ReportItemStatus.loading, clearFailure: true));

    final params = UpdateItemParams(
      itemId: event.itemId,
      itemName: state.itemName,
      description: state.description.isNotEmpty ? state.description : null,
      categoryId: state.selectedCategory?.id,
      locationId: state.selectedLocation!.id,
      newImageFile: state.imageFile,
    );

    final result = await _updateItemUseCase(params);

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
