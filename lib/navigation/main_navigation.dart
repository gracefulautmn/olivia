import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/core/utils/enums.dart'; // Pastikan UserRole ada di sini
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/history/presentation/pages/history_page.dart';
import 'package:olivia/features/home/presentation/pages/home_page.dart';
// Impor halaman klaim manual yang baru
import 'package:olivia/features/item/presentation/pages/manual_claim_page.dart'; 
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
    // Dapatkan peran pengguna dari AuthBloc
    final userRole = context.read<AuthBloc>().state.user?.role;

    if (location.startsWith(HomePage.routeName) || location == MainNavigationScaffold.routeName) {
      return 0;
    }
    if (location.startsWith(ReportItemPage.routeName)) {
      return 1;
    }
    // Logika kondisional untuk indeks ke-2
    if (userRole == UserRole.keamanan) {
      if (location.startsWith(ManualClaimPage.routeName)) return 2;
    } else {
      if (location.startsWith(ScanQrPage.routeName)) return 2;
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
    // Dapatkan peran pengguna dari AuthBloc
    final userRole = context.read<AuthBloc>().state.user?.role;

    switch (index) {
      case 0:
        GoRouter.of(context).go(HomePage.routeName);
        break;
      case 1:
        GoRouter.of(context).go(ReportItemPage.routeName);
        break;
      case 2:
        // Logika kondisional untuk navigasi
        if (userRole == UserRole.keamanan) {
          GoRouter.of(context).go(ManualClaimPage.routeName);
        } else {
          GoRouter.of(context).go(ScanQrPage.routeName);
        }
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
    // Tonton perubahan pada AuthBloc untuk membangun ulang UI jika perlu
    final userRole = context.watch<AuthBloc>().state.user?.role;
    final bool isSecurity = userRole == UserRole.keamanan;

    return Scaffold(
      body:
          widget.child, // Menampilkan halaman yang sesuai dengan rute GoRouter
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.subtleTextColor,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Lapor',
          ),
          // --- ITEM NAVIGASI DINAMIS ---
          if (isSecurity)
            const BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              activeIcon: Icon(Icons.edit),
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
