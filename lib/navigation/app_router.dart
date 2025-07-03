import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/auth/presentation/pages/login_page.dart';
import 'package:olivia/features/auth/presentation/pages/signup_page.dart';
import 'package:olivia/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:olivia/features/chat/presentation/pages/chat_list_page.dart';
import 'package:olivia/features/history/presentation/pages/history_page.dart';
import 'package:olivia/features/home/presentation/bloc/home_bloc.dart';
import 'package:olivia/features/home/presentation/pages/home_page.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/presentation/pages/item_detail_page.dart';
import 'package:olivia/features/feedback/presentation/pages/feedback_page.dart';
import 'package:olivia/features/item/presentation/pages/manual_claim_page.dart';
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
        
        final bool isGoingToUnprotectedRoute = 
            targetLocation == LoginPage.routeName || 
            targetLocation == SignUpPage.routeName;

        if (!isLoggedIn && !isGoingToUnprotectedRoute) {
          return LoginPage.routeName;
        }
        
        if (isLoggedIn && isGoingToUnprotectedRoute) {
          return HomePage.routeName;
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
              path: HomePage.routeName,
              name: HomePage.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return BlocProvider.value(
                  value: sl<HomeBloc>()..add(FetchHomeData()),
                  child: const HomePage(),
                );
              },
            ),
            // Halaman lain di dalam Shell
            GoRoute(
              path: ScanQrPage.routeName,
              name: ScanQrPage.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const ScanQrPage();
              },
            ),
            GoRoute(
              path: ManualClaimPage.routeName,
              name: ManualClaimPage.routeName,
              builder: (BuildContext context, GoRouterState state) {
                return const ManualClaimPage();
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
        // --- PERBAIKAN: Pindahkan ReportItemPage ke luar ShellRoute ---
        GoRoute(
          path: ReportItemPage.routeName,
          name: ReportItemPage.routeName,
          builder: (BuildContext context, GoRouterState state) {
            final itemToEdit = state.extra as ItemEntity?;
            return ReportItemPage(itemToEdit: itemToEdit);
          },
        ),
        // Rute lain di luar Shell
        GoRoute(
          path: ProfilePage.routeName,
          name: ProfilePage.routeName,
          builder: (context, state) => const ProfilePage(),
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
          path: ChatDetailPage.routeName,
          name: ChatDetailPage.routeName,
          builder: (context, state) {
            final chatRoomId = state.pathParameters['chatRoomId'];
            final recipientId = state.uri.queryParameters['recipientId'];
            final recipientName =
                state.uri.queryParameters['recipientName'] ?? 'Chat';
            final itemId = state.uri.queryParameters['itemId'];

            if (chatRoomId == 'new' && (recipientId == null || recipientId.isEmpty)) {
              return const Scaffold(
                  body: Center(
                      child: Text("Error: Informasi penerima tidak lengkap.")));
            }

            return ChatDetailPage(
              chatRoomId: chatRoomId,
              recipientId: recipientId ?? '',
              recipientName: recipientName,
              itemId: itemId,
            );
          },
        ),
         GoRoute(
          path: FeedbackPage.routeName,
          name: FeedbackPage.routeName,
          builder: (context, state) => const FeedbackPage(),
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
