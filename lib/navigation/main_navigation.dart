import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/features/history/presentation/pages/history_page.dart';
import 'package:olivia/features/home/presentation/pages/home_page.dart'; // Ganti dengan HomePage jika sudah ada
import 'package:olivia/features/item/presentation/pages/report_item_page.dart';
import 'package:olivia/features/item/presentation/pages/scan_qr_page.dart';
import 'package:olivia/features/notification/presentation/pages/notification_page.dart';

class MainNavigationScaffold extends StatefulWidget {
  final Widget child;
  const MainNavigationScaffold({super.key, required this.child});

  static const String routeName =
      '/main'; // Atau '/' jika ini root setelah login

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(MainNavigationScaffold.routeName) &&
        (location == MainNavigationScaffold.routeName ||
            location.startsWith(HomePage.routeName))) {
      return 0;
    }
    if (location.startsWith(ReportItemPage.routeName)) {
      return 1;
    }
    if (location.startsWith(ScanQrPage.routeName)) {
      return 2;
    }
    if (location.startsWith(NotificationPage.routeName)) {
      return 3;
    }
    if (location.startsWith(HistoryPage.routeName)) {
      return 4;
    }
    return 0; // Default
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(
          context,
        ).go(MainNavigationScaffold.routeName); // Atau HomePage.routeName
        break;
      case 1:
        GoRouter.of(context).go(ReportItemPage.routeName);
        break;
      case 2:
        GoRouter.of(context).go(ScanQrPage.routeName);
        break;
      case 3:
        GoRouter.of(context).go(NotificationPage.routeName);
        break;
      case 4:
        GoRouter.of(context).go(HistoryPage.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          widget
              .child, // Ini akan menampilkan halaman yang sesuai dengan rute GoRouter
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.subtleTextColor,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Lapor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}
