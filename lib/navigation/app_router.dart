import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/auth/presentation/pages/login_page.dart';
import 'package:olivia/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:olivia/features/chat/presentation/pages/chat_list_page.dart';
import 'package:olivia/features/history/presentation/pages/history_page.dart';
import 'package:olivia/features/home/presentation/pages/home_page.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/presentation/pages/item_detail_page.dart';
import 'package:olivia/features/item/presentation/pages/report_item_page.dart';
import 'package:olivia/features/item/presentation/pages/scan_qr_page.dart';
import 'package:olivia/features/item/presentation/pages/search_results_page.dart';
import 'package:olivia/features/notification/presentation/pages/notification_page.dart';
import 'package:olivia/features/profile/presentation/pages/profile_page.dart';
import 'package:olivia/navigation/main_navigation_scaffold.dart';

// Kunci Global untuk NavigatorState di root
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
// Kunci Global untuk NavigatorState di dalam ShellRoute (untuk bottom nav)
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRouter {
  GoRouter config() {
    final authBloc = sl<AuthBloc>(); // Ambil AuthBloc dari GetIt

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: LoginPage.routeName, // Mulai dari login
      debugLogDiagnostics: true, // Berguna untuk debugging routing
      refreshListenable: GoRouterRefreshStream(
        authBloc.stream,
      ), // Dengar perubahan state auth
      redirect: (BuildContext context, GoRouterState state) {
        final bool loggedIn = authBloc.state.status == AuthStatus.authenticated;
        final bool loggingIn = state.matchedLocation == LoginPage.routeName;

        // Jika belum login dan tidak sedang di halaman login, redirect ke login
        if (!loggedIn && !loggingIn) {
          return LoginPage.routeName;
        }
        // Jika sudah login dan masih di halaman login, redirect ke home
        if (loggedIn && loggingIn) {
          return MainNavigationScaffold.routeName;
        }
        return null; // Tidak ada redirect
      },
      routes: <RouteBase>[
        GoRoute(
          path: LoginPage.routeName,
          name: LoginPage.routeName,
          builder: (context, state) => const LoginPage(),
        ),
        // ShellRoute untuk BottomNavigationBar
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return MainNavigationScaffold(child: child);
          },
          routes: <RouteBase>[
            GoRoute(
              path:
                  MainNavigationScaffold
                      .routeName, // Biasanya '/' atau '/home' setelah login
              name: MainNavigationScaffold.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const HomePage(); // Halaman default untuk tab pertama
              },
              routes: <RouteBase>[
                // Sub-rute dari Home (jika ada yang tidak di bottom nav tapi terkait home)
                GoRoute(
                  path: ProfilePage.routeName.substring(
                    1,
                  ), // Hilangkan '/' di awal
                  name: ProfilePage.routeName,
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
            GoRoute(
              path: ReportItemPage.routeName,
              name: ReportItemPage.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const ReportItemPage();
              },
            ),
            GoRoute(
              path: ScanQrPage.routeName,
              name: ScanQrPage.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const ScanQrPage();
              },
            ),
            GoRoute(
              path: NotificationPage.routeName,
              name: NotificationPage.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const NotificationPage();
              },
            ),
            GoRoute(
              path: HistoryPage.routeName,
              name: HistoryPage.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const HistoryPage();
              },
            ),
          ],
        ),
        // Rute di luar ShellRoute (tidak memiliki bottom navigation bar)
        GoRoute(
          path: ItemDetailPage.routeName, // e.g. /item-detail/:itemId
          name: ItemDetailPage.routeName,
          builder: (context, state) {
            final itemId = state.pathParameters['itemId']!;
            // final item = state.extra as ItemEntity?; // Jika mengirim objek
            return ItemDetailPage(itemId: itemId /* item: item */);
          },
        ),
        GoRoute(
          path: SearchResultsPage.routeName, // e.g. /search
          name: SearchResultsPage.routeName,
          builder: (context, state) {
            final query = state.uri.queryParameters['query'];
            final categoryId = state.uri.queryParameters['categoryId'];
            final locationId = state.uri.queryParameters['locationId'];
            final reportType = state.uri.queryParameters['reportType'];
            return SearchResultsPage(
              initialQuery: query,
              categoryId: categoryId,
              locationId: locationId,
              reportType: reportType,
            );
          },
        ),
        GoRoute(
          path: ChatListPage.routeName, // e.g. /chats
          name: ChatListPage.routeName,
          builder: (context, state) => const ChatListPage(),
        ),
        GoRoute(
          path: ChatDetailPage.routeName, // e.g. /chat/:chatRoomId
          name: ChatDetailPage.routeName,
          builder: (context, state) {
            final chatRoomId = state.pathParameters['chatRoomId']!;
            final recipientName =
                state.uri.queryParameters['recipientName'] ?? 'Chat';
            // Anda mungkin juga perlu user ID penerima
            return ChatDetailPage(
              chatRoomId: chatRoomId,
              recipientName: recipientName,
            );
          },
        ),
      ],
    );
  }
}

// Helper class untuk GoRouter refreshListenable dari Stream
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
