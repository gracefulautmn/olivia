import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:olivia/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:olivia/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:olivia/features/auth/domain/repositories/auth_repository.dart';
import 'package:olivia/features/auth/domain/usecases/get_auth_state_changes.dart';
import 'package:olivia/features/auth/domain/usecases/get_current_user.dart';
import 'package:olivia/features/auth/domain/usecases/login_user.dart';
import 'package:olivia/features/auth/domain/usecases/logout_user.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/home/data/datasources/home_remote_data_source.dart';
import 'package:olivia/features/home/data/repositories/home_repository_impl.dart';
import 'package:olivia/features/home/domain/repositories/home_repository.dart';
import 'package:olivia/features/home/domain/usecases/get_categories.dart';
import 'package:olivia/features/home/domain/usecases/get_locations.dart';
import 'package:olivia/features/home/domain/usecases/get_recent_found_items.dart';
import 'package:olivia/features/home/domain/usecases/get_recent_lost_items.dart';
import 'package:olivia/features/home/presentation/bloc/home_bloc.dart';
import 'package:olivia/features/item/data/datasources/item_remote_data_source.dart';
import 'package:olivia/features/item/data/repositories/item_repository_impl.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';
import 'package:olivia/features/item/domain/usecases/claim_item_via_qr.dart';
import 'package:olivia/features/item/domain/usecases/get_claimed_items_history.dart';
import 'package:olivia/features/item/domain/usecases/get_item_details.dart';
import 'package:olivia/features/item/domain/usecases/report_item.dart';
import 'package:olivia/features/item/domain/usecases/search_items.dart';
import 'package:olivia/features/item/presentation/bloc/report_item/report_item_bloc.dart';
import 'package:olivia/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:olivia/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:olivia/features/profile/domain/repositories/profile_repository.dart';
import 'package:olivia/features/profile/domain/usecases/get_user_profile.dart';
import 'package:olivia/features/profile/domain/usecases/update_user_profile.dart';
import 'package:olivia/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/history/presentation/bloc/history_bloc.dart';
// ... import lainnya untuk semua layer dan fitur

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => InternetConnection());

  // Core
  // sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl())); // Jika menggunakan NetworkInfo

  // Features - Auth
  // Bloc (selalu instance baru)
  sl.registerFactory(() => AuthBloc(
        loginUser: sl(),
        getCurrentUser: sl(),
        logoutUser: sl(),
        getAuthStateChanges: sl(),
      ));
  // Usecases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetAuthStateChanges(sl()));
  // Repository
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()));
  // Datasource
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(supabaseClient: sl()));

  // Features - Home
  sl.registerFactory(() => HomeBloc(
        getCategoriesUseCase: sl(),
        getLocationsUseCase: sl(),
        getRecentFoundItemsUseCase: sl(),
        getRecentLostItemsUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetLocations(sl()));
  sl.registerLazySingleton(() => GetRecentFoundItems(sl()));
  sl.registerLazySingleton(() => GetRecentLostItems(sl()));
  sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(supabaseClient: sl()));

  // Features - Item
  sl.registerFactory(() => ReportItemBloc(reportItemUseCase: sl(), getCategoriesUseCase: sl(), getLocationsUseCase: sl()));
  // sl.registerFactory(() => ItemDetailBloc(...));
  // sl.registerFactory(() => SearchItemsBloc(...));
  // sl.registerFactory(() => ClaimItemBloc(...));

  sl.registerLazySingleton(() => ReportItem(sl()));
  sl.registerLazySingleton(() => GetItemDetails(sl()));
  sl.registerLazySingleton(() => SearchItems(sl()));
  sl.registerLazySingleton(() => ClaimItemViaQr(sl()));
  sl.registerLazySingleton(() => GetClaimedItemsHistory(sl()));

  sl.registerLazySingleton<ItemRepository>(
      () => ItemRepositoryImpl(remoteDataSource: sl(), supabaseClient: sl())); // supabaseClient untuk upload gambar
  sl.registerLazySingleton<ItemRemoteDataSource>(
      () => ItemRemoteDataSourceImpl(supabaseClient: sl()));

  // Features - Profile
  sl.registerFactory(() => ProfileBloc(getUserProfile: sl(), updateUserProfile: sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(supabaseClient: sl()));

  // Features - History
  sl.registerFactory(() => HistoryBloc(getClaimedItemsHistory: sl()));


  // ... Registrasi untuk fitur Notification dan Chat serupa
}