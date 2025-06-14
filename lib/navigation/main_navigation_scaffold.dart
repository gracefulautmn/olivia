import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:olivia/features/chat/presentation/pages/chat_list_page.dart';
import 'package:olivia/features/feedback/presentation/pages/feedback_page.dart';
import 'package:olivia/features/history/presentation/pages/history_page.dart';
import 'package:olivia/features/home/presentation/pages/home_page.dart';
import 'package:olivia/features/item/presentation/pages/report_item_page.dart';
import 'package:olivia/features/item/presentation/pages/scan_qr_page.dart';
import 'package:olivia/features/notification/presentation/pages/notification_page.dart';

class MainNavigationScaffold extends StatefulWidget {
  final Widget child; // Widget yang akan ditampilkan di body (halaman aktif)

  const MainNavigationScaffold({
    super.key,
    required this.child,
  });

  static const String routeName = '/main'; // Rute dasar untuk ShellRoute

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  // Fungsi untuk menentukan index BottomNavigationBar yang aktif berdasarkan rute saat ini
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    // Cocokkan dengan rute-rute yang ada di ShellRoute
    // Urutan harus sesuai dengan urutan BottomNavigationBarItem
    if (location.startsWith(MainNavigationScaffold.routeName) && (location == MainNavigationScaffold.routeName || location.startsWith(HomePage.routeName))) {
      return 0; // Beranda
    }
    if (location.startsWith(ReportItemPage.routeName)) {
      return 1; // Lapor
    }
    if (location.startsWith(ScanQrPage.routeName)) {
      return 2; // Scan
    }
    if (location.startsWith(NotificationPage.routeName)) {
      return 3; // Notifikasi
    }
    if (location.startsWith(HistoryPage.routeName)) {
      return 4; // Riwayat
    }
    return 0; // Default ke Beranda jika tidak ada yang cocok
  }

  // Fungsi untuk navigasi saat item BottomNavigationBar di-tap
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: // Beranda
        // GoRouter akan menangani navigasi ke rute default ShellRoute jika MainNavigationScaffold.routeName
        // atau secara eksplisit ke HomePage.routeName jika HomePage adalah bagian dari MainNavigationScaffold.routeName
        context.go(MainNavigationScaffold.routeName); // Atau context.go(HomePage.routeName) jika itu rute tab pertama
        break;
      case 1: // Lapor
        context.go(ReportItemPage.routeName);
        break;
      case 2: // Scan
        context.go(ScanQrPage.routeName);
        break;
      case 3: // Notifikasi
        context.go(NotificationPage.routeName);
        break;
      case 4: // Riwayat
        context.go(HistoryPage.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child, // Menampilkan halaman yang sesuai dengan rute GoRouter
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.subtleTextColor.withOpacity(0.8),
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        selectedFontSize: 12, // Ukuran font label yang dipilih
        unselectedFontSize: 11, // Ukuran font label yang tidak dipilih
        iconSize: 24, // Ukuran ikon
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
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
      // floatingActionButton: FloatingActionButton(
      // onPressed: () => _showSupportOptions(context),
      // backgroundColor: Theme.of(context).primaryColor,
      // child: const Icon(Icons.support_agent_outlined, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
