import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:olivia/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:olivia/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:olivia/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:olivia/features/feedback/domain/usecases/submit_feedback.dart';
import 'package:olivia/features/feedback/presentation/bloc/feedback_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core & Utils (jika ada NetworkInfo)
// import 'package:olivia/core/network/network_info.dart';

// Auth Feature
import 'package:olivia/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:olivia/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:olivia/features/auth/domain/repositories/auth_repository.dart';
import 'package:olivia/features/auth/domain/usecases/get_auth_state_changes.dart';
import 'package:olivia/features/auth/domain/usecases/get_current_user.dart';
import 'package:olivia/features/auth/domain/usecases/login_user.dart';
import 'package:olivia/features/auth/domain/usecases/logout_user.dart';
import 'package:olivia/features/auth/domain/usecases/signup_user.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';

// Home Feature
import 'package:olivia/features/home/data/datasources/home_remote_data_source.dart';
import 'package:olivia/features/home/data/repositories/home_repository_impl.dart';
import 'package:olivia/features/home/domain/repositories/home_repository.dart';
import 'package:olivia/features/home/domain/usecases/get_categories.dart';
import 'package:olivia/features/home/domain/usecases/get_locations.dart';
import 'package:olivia/features/home/domain/usecases/get_recent_found_items.dart';
import 'package:olivia/features/home/domain/usecases/get_recent_lost_items.dart';
import 'package:olivia/features/home/presentation/bloc/home_bloc.dart';

// Item Feature
import 'package:olivia/features/item/data/datasources/item_remote_data_source.dart';
import 'package:olivia/features/item/data/repositories/item_repository_impl.dart';
import 'package:olivia/features/item/domain/repositories/item_repository.dart';
import 'package:olivia/features/item/domain/usecases/claim_item_via_qr.dart';
import 'package:olivia/features/item/domain/usecases/delete_item.dart'; // Import DeleteItem jika belum ada
import 'package:olivia/features/item/domain/usecases/get_item_details.dart';
import 'package:olivia/features/item/domain/usecases/report_item.dart';
import 'package:olivia/features/item/domain/usecases/search_items.dart';
import 'package:olivia/features/item/domain/usecases/update_item.dart'; // Import UpdateItem jika belum ada
import 'package:olivia/features/item/presentation/bloc/report_item/report_item_bloc.dart';
import 'package:olivia/features/item/presentation/bloc/search_items_bloc.dart';
import 'package:olivia/features/item/presentation/pages/item_detail_page.dart';
import 'package:olivia/features/item/presentation/pages/scan_qr_page.dart';

// Profile Feature
import 'package:olivia/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:olivia/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:olivia/features/profile/domain/repositories/profile_repository.dart';
import 'package:olivia/features/profile/domain/usecases/get_user_profile.dart';
import 'package:olivia/features/profile/domain/usecases/update_user_profile.dart';
import 'package:olivia/features/profile/presentation/bloc/profile_bloc.dart';

// History Feature
import 'package:olivia/features/history/domain/usecases/get_global_claim_history.dart';
import 'package:olivia/features/history/presentation/bloc/global_history_bloc.dart';

// Notification Feature
import 'package:olivia/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:olivia/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:olivia/features/notification/domain/repositories/notification_repository.dart';
import 'package:olivia/features/notification/domain/usecases/get_notifications.dart';
import 'package:olivia/features/notification/domain/usecases/get_unread_notification_count.dart';
import 'package:olivia/features/notification/domain/usecases/mark_all_notifications_as_read.dart';
import 'package:olivia/features/notification/domain/usecases/mark_notification_as_read.dart';
import 'package:olivia/features/notification/presentation/bloc/notification_bloc.dart';

// Chat Feature
import 'package:olivia/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:olivia/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:olivia/features/chat/domain/repositories/chat_repository.dart';
import 'package:olivia/features/chat/domain/usecases/create_or_get_chat_room.dart';
import 'package:olivia/features/chat/domain/usecases/get_chat_rooms.dart';
import 'package:olivia/features/chat/domain/usecases/get_messages.dart';
import 'package:olivia/features/chat/domain/usecases/mark_messages_as_read.dart';
import 'package:olivia/features/chat/domain/usecases/send_message.dart';
import 'package:olivia/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:olivia/features/chat/presentation/bloc/chat_detail/chat_detail_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // === EXTERNAL ===
  // PERBAIKAN: Menggunakan registerSingleton untuk instance yang sudah ada
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);
  // PERBAIKAN: Nama kelas yang benar dari package
  sl.registerLazySingleton(() => InternetConnection());

  // === CORE ===
  // sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ===================================================================
  //                             FITUR AUTH
  // ===================================================================
  // BLoC
  sl.registerFactory(() => AuthBloc(
        loginUser: sl(),
        signUpUser: sl(),
        getCurrentUser: sl(),
        logoutUser: sl(),
        getAuthStateChanges: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SignUpUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetAuthStateChanges(sl()));

  // Repository & DataSource
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(supabaseClient: sl()));

  // ===================================================================
  //                             FITUR HOME
  // ===================================================================
  // BLoC
  sl.registerFactory(() => HomeBloc(
        getCategoriesUseCase: sl(),
        getLocationsUseCase: sl(),
        searchItemsUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetLocations(sl()));
  sl.registerLazySingleton(() => GetRecentFoundItems(sl()));
  sl.registerLazySingleton(() => GetRecentLostItems(sl()));

  // Repository & DataSource
  sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(supabaseClient: sl()));
  
  // ===================================================================
  //                      FITUR ITEM, HISTORY, SCAN
  // ===================================================================
  // BLoC / Cubit
  sl.registerFactory(() => ReportItemBloc(
        reportItemUseCase: sl(),
        getCategoriesUseCase: sl(),
        getLocationsUseCase: sl(),
      ));
  sl.registerFactory(() => ItemDetailCubit(sl()));
  sl.registerFactory(() => ScanClaimCubit(sl()));
  sl.registerFactory(() => SearchItemsBloc(
        searchItemsUseCase: sl(),
        getCategoriesUseCase: sl(),
        getLocationsUseCase: sl(),
      ));
  // PERBAIKAN: Menggunakan BLoC dan Use Case yang benar untuk riwayat
  sl.registerFactory(() => GlobalHistoryBloc(sl<GetGlobalClaimHistory>()));

  // Use Cases
  sl.registerLazySingleton(() => ReportItem(sl()));
  sl.registerLazySingleton(() => GetItemDetails(sl()));
  sl.registerLazySingleton(() => SearchItems(sl()));
  sl.registerLazySingleton(() => ClaimItemViaQr(sl()));
  sl.registerLazySingleton(() => UpdateItem(sl()));
  sl.registerLazySingleton(() => DeleteItem(sl()));
  // PERBAIKAN: Mendaftarkan use case riwayat global yang baru
  sl.registerLazySingleton(() => GetGlobalClaimHistory(sl()));

  // Repository & DataSource
  // PERBAIKAN: ItemRepositoryImpl tidak lagi memerlukan SupabaseClient
  sl.registerLazySingleton<ItemRepository>(
      () => ItemRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ItemRemoteDataSource>(
      () => ItemRemoteDataSourceImpl(supabaseClient: sl()));

  // ===================================================================
  //                            FITUR PROFILE
  // ===================================================================
  // BLoC
  sl.registerFactory(() => ProfileBloc(
        getUserProfile: sl(),
        updateUserProfile: sl(),
        authBloc: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  
  // Repository & DataSource
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(supabaseClient: sl()));

  // ===================================================================
  //                         FITUR NOTIFICATION
  // ===================================================================
  // BLoC
  sl.registerFactory(() => NotificationBloc(
        getNotificationsUseCase: sl(),
        markNotificationAsReadUseCase: sl(),
        markAllNotificationsAsReadUseCase: sl(),
        notificationRepository: sl(), // Mungkin bisa dihapus jika tidak digunakan langsung
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsRead(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsRead(sl()));
  sl.registerLazySingleton(() => GetUnreadNotificationCount(sl()));
  
  // Repository & DataSource
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(supabaseClient: sl()));
  
  // ===================================================================
  //                             FITUR CHAT
  // ===================================================================
  // BLoC
  sl.registerFactory(() => ChatListBloc(getChatRoomsUseCase: sl()));
  sl.registerFactory(() => ChatDetailBloc(
        createOrGetChatRoomUseCase: sl(),
        getMessagesUseCase: sl(),
        sendMessageUseCase: sl(),
        markMessagesAsReadUseCase: sl(),
      ));
      
  // Use Cases
  sl.registerLazySingleton(() => GetChatRooms(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => CreateOrGetChatRoom(sl()));
  sl.registerLazySingleton(() => MarkMessagesAsRead(sl()));
  
  // Repository & DataSource
  sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(supabaseClient: sl()));
  
  // ===================================================================
  //                       FITUR FEEDBACK (BARU)
  // ===================================================================
  // BLoC
  sl.registerFactory(() => FeedbackBloc(sl()));

  // Use Case
  sl.registerLazySingleton(() => SubmitFeedback(sl()));

  // Repository & DataSource
  sl.registerLazySingleton<FeedbackRepository>(() => FeedbackRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<FeedbackRemoteDataSource>(() => FeedbackRemoteDataSourceImpl(supabaseClient: sl()));

}
