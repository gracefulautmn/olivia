import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/auth/presentation/pages/login_page.dart';
import 'package:olivia/features/auth/presentation/pages/signup_page.dart';
import 'package:olivia/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:olivia/features/chat/presentation/pages/chat_list_page.dart';
import 'package:olivia/features/history/presentation/pages/history_page.dart';
import 'package:olivia/features/home/presentation/pages/home_page.dart';
import 'package:olivia/features/item/presentation/pages/item_detail_page.dart';
import 'package:olivia/features/item/presentation/pages/report_item_page.dart';
import 'package:olivia/features/item/presentation/pages/scan_qr_page.dart';
import 'package:olivia/features/item/presentation/pages/search_results_page.dart';
import 'package:olivia/features/notification/presentation/pages/notification_page.dart';
import 'package:olivia/features/profile/presentation/pages/profile_page.dart'; // Pastikan ini diimpor
import 'package:olivia/navigation/main_navigation_scaffold.dart';
import 'package:olivia/features/feedback/presentation/pages/feedback_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  GoRouter config() {
    final authBloc = sl<AuthBloc>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: LoginPage.routeName,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final bool isLoggedIn = authBloc.state.status == AuthStatus.authenticated;
        final String targetLocation = state.matchedLocation;
        final unprotectedRoutes = [LoginPage.routeName, SignUpPage.routeName];

        if (isLoggedIn) {
          if (unprotectedRoutes.contains(targetLocation)) {
            return MainNavigationScaffold.routeName; // Path ke ShellRoute (misal '/main')
          }
        } else {
          if (!unprotectedRoutes.contains(targetLocation)) {
            return LoginPage.routeName;
          }
        }
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: LoginPage.routeName,
          name: LoginPage.routeName,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: SignUpPage.routeName,
          name: SignUpPage.routeName,
          builder: (context, state) => const SignUpPage(),
        ),
        // ShellRoute untuk BottomNavigationBar
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return MainNavigationScaffold(child: child);
          },
          routes: <RouteBase>[
            // Rute untuk tab pertama (Beranda) dan sub-rutenya (Profil)
            GoRoute(
              path: MainNavigationScaffold.routeName, // Misal: '/main'
              name: MainNavigationScaffold.routeName, // Nama untuk rute dasar Shell
              builder: (BuildContext context, GoRouterState state) {
                // Ini adalah halaman default yang ditampilkan saat ShellRoute aktif
                // atau saat navigasi ke MainNavigationScaffold.routeName
                return const HomePage();
              },
              routes: <RouteBase>[
                // ProfilePage sebagai sub-rute dari /main (atau HomePage)
                // Ini berarti path lengkapnya akan menjadi /main/profile
                GoRoute(
                  // Path di sini relatif terhadap parent ('/main')
                  // Jika ProfilePage.routeName adalah '/profile', maka cukup 'profile'
                  path: 'profile', // Langsung nama path tanpa '/' di awal
                  name: ProfilePage.routeName, // Nama rute tetap '/profile' untuk kemudahan `namedNavigation`
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
            // Rute untuk tab kedua (Lapor)
            GoRoute(
              path: ReportItemPage.routeName, // Misal: '/report-item'
              name: ReportItemPage.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const ReportItemPage();
              },
            ),
            // Rute untuk tab ketiga (Scan)
            GoRoute(
              path: ScanQrPage.routeName, // Misal: '/scan-qr'
              name: ScanQrPage.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const ScanQrPage();
              },
            ),
            // Rute untuk tab keempat (Notifikasi)
            GoRoute(
              path: NotificationPage.routeName, // Misal: '/notifications'
              name: NotificationPage.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const NotificationPage();
              },
            ),
            // Rute untuk tab kelima (Riwayat)
            GoRoute(
              path: HistoryPage.routeName, // Misal: '/history'
              name: HistoryPage.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const HistoryPage();
              },
            ),
          ],
        ),
        // Rute lain di luar ShellRoute (tidak akan memiliki BottomNavigationBar)
        GoRoute(
          path: ItemDetailPage.routeName,
          name: ItemDetailPage.routeName,
          builder: (context, state) {
            final itemId = state.pathParameters['itemId']!;
            return ItemDetailPage(itemId: itemId);
          },
        ),
        GoRoute(
          path: SearchResultsPage.routeName,
          name: SearchResultsPage.routeName,
          builder: (context, state) {
            final query = state.uri.queryParameters['query'];
            final categoryId = state.uri.queryParameters['categoryId'];
            final locationId = state.uri.queryParameters['locationId'];
            return SearchResultsPage(
              initialQuery: query,
              categoryId: categoryId,
              locationId: locationId,
            );
          },
        ),
        // GoRoute(
        //   path: ChatListPage.routeName,
        //   name: ChatListPage.routeName,
        //   builder: (context, state) => const ChatListPage(),
        // ),
        GoRoute(
          path: FeedbackPage.routeName,
          name: FeedbackPage.routeName,
          parentNavigatorKey: _rootNavigatorKey, // Tampil di atas shell
          builder: (context, state) => const FeedbackPage(),
        ),
        GoRoute(
          path: ChatDetailPage.routeName,
          name: ChatDetailPage.routeName,
          builder: (context, state) {
            final chatRoomId = state.pathParameters['chatRoomId'];
            final recipientId = state.uri.queryParameters['recipientId'];
            final recipientName = state.uri.queryParameters['recipientName'] ?? 'Chat';
            final itemId = state.uri.queryParameters['itemId'];

            if (recipientId == null || recipientId.isEmpty) {
              return const Scaffold(body: Center(child: Text("Error: Informasi penerima tidak lengkap.")));
            }
            return ChatDetailPage(
              chatRoomId: chatRoomId,
              recipientId: recipientId,
              recipientName: recipientName,
              itemId: itemId,
            );
          },
        ),
      ],
    );
  }
}

// Helper class GoRouterRefreshStream (tetap sama)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}