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
import 'package:olivia/features/feedback/presentation/pages/feedback_page.dart';
import 'package:olivia/features/item/presentation/pages/report_item_page.dart';
import 'package:olivia/features/item/presentation/pages/scan_qr_page.dart';
import 'package:olivia/features/item/presentation/pages/search_results_page.dart';
import 'package:olivia/features/notification/presentation/pages/notification_page.dart';
import 'package:olivia/features/profile/presentation/pages/profile_page.dart';
import 'package:olivia/navigation/main_navigation_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  GoRouter config() {
    final authBloc = sl<AuthBloc>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: LoginPage.routeName,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final bool isLoggedIn =
            authBloc.state.status == AuthStatus.authenticated;
        final String targetLocation = state.matchedLocation;
        final unprotectedRoutes = [LoginPage.routeName, SignUpPage.routeName];

        if (isLoggedIn) {
          if (unprotectedRoutes.contains(targetLocation)) {
            return MainNavigationScaffold.routeName;
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
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return MainNavigationScaffold(child: child);
          },
          routes: <RouteBase>[
            GoRoute(
              path: MainNavigationScaffold.routeName,
              name: MainNavigationScaffold.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const HomePage();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'profile',
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
              path: FeedbackPage.routeName, // Contoh: /feedback
              name: FeedbackPage.routeName,
              builder: (context, state) => const FeedbackPage(),
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
            // reportType tidak lagi diperlukan di sini
            return SearchResultsPage(
              initialQuery: query,
              categoryId: categoryId,
              locationId: locationId,
            );
          },
        ),
        GoRoute(
          path: ChatListPage.routeName,
          name: ChatListPage.routeName,
          builder: (context, state) => const ChatListPage(),
        ),
        GoRoute(
          path: ChatDetailPage.routeName, // Contoh: /chat/:chatRoomId
          name: ChatDetailPage.routeName,
          builder: (context, state) {
            final chatRoomId = state.pathParameters['chatRoomId'];
            final recipientId = state.uri.queryParameters['recipientId'];
            final recipientName =
                state.uri.queryParameters['recipientName'] ?? 'Chat';
            final itemId = state.uri.queryParameters['itemId'];

            // Cek jika kita sedang membuat chat BARU.
            if (chatRoomId == 'new' && (recipientId == null || recipientId.isEmpty)) {
              return const Scaffold(
                  body: Center(
                      child: Text("Error: Informasi penerima tidak lengkap.")));
            }

            return ChatDetailPage(
              chatRoomId: chatRoomId,
              // PERBAIKAN: Berikan string kosong jika recipientId null.
              // Ini akan memenuhi syarat non-nullable dari parameter.
              // Logika di dalam ChatDetailPage diasumsikan akan memprioritaskan chatRoomId
              // jika recipientId yang diterima adalah string kosong.
              recipientId: recipientId ?? '',
              recipientName: recipientName,
              itemId: itemId,
            );
          },
        ),
      ],
    );
  }
}

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
