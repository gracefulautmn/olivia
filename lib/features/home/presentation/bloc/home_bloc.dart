import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/core/utils/enums.dart'; // Pastikan enum ItemStatus dan ReportType ada di sini
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/item_preview.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/home/domain/usecases/get_categories.dart';
import 'package:olivia/features/home/domain/usecases/get_locations.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
// PERBAIKAN: Menggunakan use case SearchItems yang lebih fleksibel
import 'package:olivia/features/item/domain/usecases/search_items.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCategories getCategoriesUseCase;
  final GetLocations getLocationsUseCase;
  // PERBAIKAN: Mengganti use case spesifik dengan yang lebih umum
  final SearchItems searchItemsUseCase;

  HomeBloc({
    required this.getCategoriesUseCase,
    required this.getLocationsUseCase,
    required this.searchItemsUseCase, // Menggunakan dependensi baru
  }) : super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
  }

  Future<void> _onFetchHomeData(
    FetchHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Mengambil data secara paralel
      final results = await Future.wait([
        getCategoriesUseCase(NoParams()),
        getLocationsUseCase(NoParams()),
        // PERBAIKAN: Memanggil searchItems dengan reportType DAN status yang benar
        searchItemsUseCase(const SearchItemsParams(
          reportType: 'penemuan',
          status: 'ditemukan_tersedia', // Hanya ambil yang tersedia
          limit: 6,
        )),
        // PERBAIKAN: Memanggil searchItems dengan reportType DAN status yang benar
        searchItemsUseCase(const SearchItemsParams(
          reportType: 'kehilangan',
          status: 'hilang', // Hanya ambil yang masih hilang
          limit: 6,
        )),
      ]);

      // Mengekstrak hasil dan menangani error
      final categoriesResult = results[0] as Either<Failure, List<CategoryEntity>>;
      final locationsResult = results[1] as Either<Failure, List<LocationEntity>>;
      // PERBAIKAN: ItemEntity dari SearchItems perlu di-map ke ItemPreviewEntity
      final recentFoundItemsResult = results[2] as Either<Failure, List<ItemEntity>>;
      final recentLostItemsResult = results[3] as Either<Failure, List<ItemEntity>>;

      // Fungsi helper untuk memeriksa kegagalan
      Failure? anyFailure;
      T? extractData<T>(Either<Failure, T> result) {
        T? data;
        result.fold(
          (failure) => anyFailure = failure,
          (d) => data = d,
        );
        return data;
      }
      
      final categories = extractData(categoriesResult);
      if (anyFailure != null) {
        emit(HomeError(anyFailure!.message));
        return;
      }

      final locations = extractData(locationsResult);
      if (anyFailure != null) {
        emit(HomeError(anyFailure!.message));
        return;
      }
      
      final recentFoundItemsEntities = extractData(recentFoundItemsResult);
      if (anyFailure != null) {
        emit(HomeError(anyFailure!.message));
        return;
      }

      final recentLostItemsEntities = extractData(recentLostItemsResult);
      if (anyFailure != null) {
        emit(HomeError(anyFailure!.message));
        return;
      }

      // Konversi dari ItemEntity ke ItemPreviewEntity
      final recentFoundItems = recentFoundItemsEntities?.map((item) => ItemPreviewEntity.fromItemEntity(item)).toList() ?? [];
      final recentLostItems = recentLostItemsEntities?.map((item) => ItemPreviewEntity.fromItemEntity(item)).toList() ?? [];

      emit(
        HomeLoaded(
          categories: categories ?? [],
          locations: locations ?? [],
          recentFoundItems: recentFoundItems,
          recentLostItems: recentLostItems,
        ),
      );

    } catch (e) {
      emit(HomeError("An unexpected error occurred: ${e.toString()}"));
    }
  }
}

// Anda perlu menambahkan factory constructor ini ke kelas ItemPreviewEntity Anda
// agar bisa melakukan konversi dari ItemEntity.
// Contoh di file: lib/features/home/domain/entities/item_preview.dart
/*
factory ItemPreviewEntity.fromItemEntity(ItemEntity item) {
  return ItemPreviewEntity(
    id: item.id,
    itemName: item.itemName,
    imageUrl: item.imageUrl,
    reportType: item.reportType,
    categoryName: item.category?.name,
    locationName: item.location?.name,
  );
}
*/
