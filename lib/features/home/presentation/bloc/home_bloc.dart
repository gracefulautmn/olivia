import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/item_preview.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/home/domain/usecases/get_categories.dart';
import 'package:olivia/features/home/domain/usecases/get_locations.dart';
import 'package:olivia/features/home/domain/usecases/get_recent_found_items.dart';
import 'package:olivia/features/home/domain/usecases/get_recent_lost_items.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCategories getCategoriesUseCase;
  final GetLocations getLocationsUseCase;
  final GetRecentFoundItems getRecentFoundItemsUseCase;
  final GetRecentLostItems getRecentLostItemsUseCase;

  HomeBloc({
    required this.getCategoriesUseCase,
    required this.getLocationsUseCase,
    required this.getRecentFoundItemsUseCase,
    required this.getRecentLostItemsUseCase,
  }) : super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
  }

  Future<void> _onFetchHomeData(
    FetchHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final categoriesResult = await getCategoriesUseCase(NoParams());
      final locationsResult = await getLocationsUseCase(NoParams());
      final recentFoundItemsResult = await getRecentFoundItemsUseCase(
        const GetRecentItemsParams(limit: 6),
      );
      final recentLostItemsResult = await getRecentLostItemsUseCase(
        const GetRecentItemsParams(limit: 6),
      );

      // Menggunakan fold untuk menangani Either
      Failure? anyFailure;
      List<CategoryEntity> categories = [];
      List<LocationEntity> locations = [];
      List<ItemPreviewEntity> recentFoundItems = [];
      List<ItemPreviewEntity> recentLostItems = [];

      categoriesResult.fold(
        (failure) => anyFailure = failure,
        (data) => categories = data,
      );
      if (anyFailure != null) {
        emit(HomeError(anyFailure!.message));
        return;
      }

      locationsResult.fold(
        (failure) => anyFailure = failure,
        (data) => locations = data,
      );
      if (anyFailure != null) {
        emit(HomeError(anyFailure!.message));
        return;
      }

      recentFoundItemsResult.fold(
        (failure) => anyFailure = failure, // Bisa juga di-collect semua error
        (data) => recentFoundItems = data,
      );
      if (anyFailure != null) {
        // Bisa jadi beberapa data berhasil, beberapa gagal. Handle sesuai kebutuhan.
        // Untuk sekarang, jika ada satu gagal, tampilkan error.
        emit(HomeError(anyFailure!.message));
        return;
      }

      recentLostItemsResult.fold(
        (failure) => anyFailure = failure,
        (data) => recentLostItems = data,
      );
      if (anyFailure != null) {
        emit(HomeError(anyFailure!.message));
        return;
      }

      emit(
        HomeLoaded(
          categories: categories,
          locations: locations,
          recentFoundItems: recentFoundItems,
          recentLostItems: recentLostItems,
        ),
      );
    } catch (e) {
      emit(HomeError("An unexpected error occurred: ${e.toString()}"));
    }
  }
}
