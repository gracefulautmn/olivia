import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:olivia/features/feedback/presentation/pages/feedback_page.dart';
import 'package:olivia/features/history/presentation/pages/history_page.dart';
import 'package:olivia/features/home/presentation/pages/home_page.dart';
import 'package:olivia/features/item/presentation/pages/manual_claim_page.dart';
import 'package:olivia/features/item/presentation/pages/report_item_page.dart';
import 'package:olivia/features/item/presentation/pages/scan_qr_page.dart';
import 'package:olivia/features/notification/presentation/pages/notification_page.dart';

class MainNavigationScaffold extends StatefulWidget {
  final Widget child;
  const MainNavigationScaffold({super.key, required this.child});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    final userRole = context.read<AuthBloc>().state.user?.role;

    if (location == HomePage.routeName) {
      return 0;
    }
    if (location == ReportItemPage.routeName) {
      return 1;
    }
    if (userRole == UserRole.keamanan) {
      if (location == ManualClaimPage.routeName) return 2;
    } else {
      if (location == ScanQrPage.routeName) return 2;
    }
    if (location == NotificationPage.routeName) {
      return 3;
    }
    if (location == HistoryPage.routeName) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final userRole = context.read<AuthBloc>().state.user?.role;

    switch (index) {
      case 0:
        context.goNamed(HomePage.routeName);
        break;
      case 1:
        context.goNamed(ReportItemPage.routeName);
        break;
      case 2:
        if (userRole == UserRole.keamanan) {
          context.goNamed(ManualClaimPage.routeName);
        } else {
          context.goNamed(ScanQrPage.routeName);
        }
        break;
      case 3:
        context.goNamed(NotificationPage.routeName);
        break;
      case 4:
        context.goNamed(HistoryPage.routeName);
        break;
    }
  }

  void _showSupportOptions(BuildContext context) {
    // --- PERBAIKAN DI SINI ---
    // Ambil role pengguna dari AuthBloc yang tersedia di context
    final userRole = context.read<AuthBloc>().state.user?.role;
    final bool isCurrentUserSecurity = userRole == UserRole.keamanan;

    const String securityUserId = 'af7321dd-7ce2-4112-999e-0b88edad8d0d';
    const String securityUserName = 'Pihak Keamanan';

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Lapor Bug / Beri Masukan Aplikasi'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.pushNamed(FeedbackPage.routeName);
                },
              ),
              // --- KONDISI DITERAPKAN DI SINI ---
              // Hanya tampilkan opsi "Hubungi Keamanan" jika pengguna BUKAN keamanan
              if (!isCurrentUserSecurity)
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: const Text('Hubungi Keamanan'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    context.pushNamed(
                      ChatDetailPage.routeName,
                      pathParameters: {'chatRoomId': 'new'},
                      queryParameters: {
                        'recipientId': securityUserId,
                        'recipientName': securityUserName,
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.watch<AuthBloc>().state.user?.role;
    final bool isSecurity = userRole == UserRole.keamanan;
    final int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      floatingActionButton: currentIndex == 0 // Hanya tampilkan di Beranda
          ? FloatingActionButton(
              onPressed: () => _showSupportOptions(context),
              backgroundColor: Colors.red,
              shape: const CircleBorder(),
              child: const Icon(Icons.support_agent_outlined, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.subtleTextColor.withOpacity(0.8),
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(index, context),
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Lapor',
          ),
          if (isSecurity)
            const BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              activeIcon: Icon(Icons.edit_document),
              label: 'Klaim',
            )
          else
            const BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_outlined),
              activeIcon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}
