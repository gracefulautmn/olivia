// lib/routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/features/auth/presentation/cubit_or_bloc/auth_cubit.dart';
import 'package:olivia/features/auth/presentation/pages/login_page.dart';
import 'package:olivia/features/auth/presentation/pages/profile_page.dart';
import 'package:olivia/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:olivia/features/chat/presentation/pages/chat_list_page.dart';
import 'package:olivia/features/items/presentation/pages/claimed_items_history_page.dart';
import 'package:olivia/features/items/presentation/pages/home_page.dart';
import 'package:olivia/features/items/presentation/pages/item_detail_page.dart';
import 'package:olivia/features/items/presentation/pages/item_search_result_page.dart';
import 'package:olivia/features/items/presentation/pages/report_item_page.dart';
import 'package:olivia/features/notifications/presentation/pages/notification_page.dart';
import 'package:olivia/features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import 'package:olivia/core/widgets/bottom_nav_shell.dart'; // Akan kita buat

// Kunci Global untuk NavigatorState, berguna untuk navigasi dari luar widget tree jika diperlukan
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  // Nama rute sebagai konstanta untuk menghindari typo
  static const String splashPath = '/splash'; // Atau halaman loading awal
  static const String loginPath = '/login';
  static const String homePath = '/home';
  static const String reportItemPath = '/report-item';
  static const String scanQrPath = '/scan-qr';
  static const String notificationsPath = '/notifications';
  static const String historyPath = '/history'; // Riwayat klaim
  static const String profilePath = '/profile';
  static const String itemDetailPath = '/item/:itemId'; // Dengan parameter itemId
  static const String itemSearchPath = '/search';
  static const String chatListPath = '/chats';
  static const String chatDetailPath = '/chat/:chatRoomId'; // Dengan parameter chatRoomId

  static GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: loginPath, // Atau splashPath jika ada
    debugLogDiagnostics: true, // Aktifkan log untuk debugging routing
    routes: [
      // Rute di luar Shell (tanpa BottomNavigationBar)
      GoRoute(
        path: loginPath,
        name: loginPath,
        builder: (context, state) => const LoginPage(),
      ),
      // ShellRoute untuk halaman-halaman dengan BottomNavigationBar
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // `child` adalah widget halaman yang aktif sesuai rute
          return BottomNavShell(child: child); // Widget kerangka dengan BottomNav
        },
        routes: [
          GoRoute(
            path: homePath,
            name: homePath,
            pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
            routes: [ // Sub-rute dari home
              GoRoute(
                path: 'profile', // relative path: /home/profile
                name: profilePath,
                parentNavigatorKey: _rootNavigatorKey, // Tampilkan di atas shell
                builder: (context, state) => const ProfilePage(),
              ),
              GoRoute(
                path: 'item/:itemId', // relative path: /home/item/:itemId
                name: itemDetailPath,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final itemId = state.pathParameters['itemId']!;
                  return ItemDetailPage(itemId: itemId);
                },
              ),
              GoRoute(
                path: 'search', // relative path: /home/search
                name: itemSearchPath,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                    // Ambil query params jika ada, misal: /home/search?category=Kunci
                    final String? category = state.uri.queryParameters['category'];
                    final String? location = state.uri.queryParameters['location'];
                    final String? type = state.uri.queryParameters['type']; // 'lost' atau 'found'
                    final String? searchQuery = state.uri.queryParameters['q'];
                    return ItemSearchResultPage(
                        categoryFilter: category,
                        locationFilter: location,
                        reportTypeFilter: type,
                        searchQuery: searchQuery,
                    );
                },
              ),
            ]
          ),
          GoRoute(
            path: reportItemPath,
            name: reportItemPath,
            pageBuilder: (context, state) => const NoTransitionPage(child: ReportItemPage()),
          ),
          GoRoute(
            path: scanQrPath,
            name: scanQrPath,
            pageBuilder: (context, state) => const NoTransitionPage(child: QrScannerPage()),
          ),
          GoRoute(
            path: notificationsPath,
            name: notificationsPath,
            pageBuilder: (context, state) => const NoTransitionPage(child: NotificationPage()),
          ),
          GoRoute(
            path: historyPath,
            name: historyPath,
            pageBuilder: (context, state) => const NoTransitionPage(child: ClaimedItemsHistoryPage()),
          ),
        ],
      ),
      // Rute lain yang mungkin tidak menggunakan Shell utama, misal halaman chat
       GoRoute(
        path: chatListPath,
        name: chatListPath,
        parentNavigatorKey: _rootNavigatorKey, // Tampilkan di atas shell jika diakses dari notif/profil
        builder: (context, state) => const ChatListPage(),
        routes: [
          GoRoute(
            path: ':chatRoomId', // relative path: /chats/:chatRoomId
            name: chatDetailPath,
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final chatRoomId = state.pathParameters['chatRoomId']!;
              // Anda mungkin juga perlu mengirim user ID lawan bicara atau info item terkait
              return ChatDetailPage(chatRoomId: chatRoomId);
            },
          ),
        ]
      ),
      // Tambahkan rute splash jika ada
      // GoRoute(
      //   path: splashPath,
      //   name: splashPath,
      //   builder: (context, state) => SplashScreen(), // atau LoadingScreen
      // ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authCubit = context.read<AuthCubit>();
      final authState = authCubit.state;

      final bool loggedIn = authState is AuthAuthenticated;
      final String location = state.uri.toString(); // Menggunakan uri.toString() untuk path lengkap termasuk query params

      // Jika pengguna belum login dan tidak sedang di halaman login (atau splash), redirect ke login
      if (!loggedIn && location != loginPath && location != splashPath) {
        return loginPath;
      }

      // Jika pengguna sudah login dan mencoba mengakses halaman login, redirect ke home
      if (loggedIn && location == loginPath) {
        return homePath;
      }

      // Tidak ada redirect, lanjutkan ke tujuan
      return null;
    },
    // refreshListenable: GoRouterRefreshStream(context.watch<AuthCubit>().stream), // Untuk auto-redirect saat state auth berubah
  );
}

// Opsional: Untuk menghilangkan transisi antar halaman di BottomNav
// class NoTransitionPage<T> extends CustomTransitionPage<T> {
//   const NoTransitionPage({required Widget child, LocalKey? key, String? name})
//       : super(
//           key: key,
//           name: name,
//           child: child,
//           transitionsBuilder: _transitionsBuilder,
//         );

//   static Widget _transitionsBuilder(
//     BuildContext context,
//     Animation<double> animation,
//     Animation<double> secondaryAnimation,
//     Widget child,
//   ) {
//     return child; // Tidak ada animasi
//   }
// }

// Atau jika Anda menggunakan versi GoRouter yang lebih baru,
// `pageBuilder` bisa langsung return `MaterialPage` atau `CupertinoPage`
// atau `NoTransitionPage` dari GoRouter sendiri jika tersedia.
// Untuk ShellRoute, `NoTransitionPage` biasanya digunakan agar halaman dalam shell tidak beranimasi saat berganti tab.
