// lib/core/widgets/bottom_nav_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/routes.dart'; // Untuk mengakses nama rute

class BottomNavShell extends StatefulWidget {
  final Widget child;

  const BottomNavShell({
    required this.child,
    super.key,
  });

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  // Indeks untuk BottomNavigationBar
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRouter.homePath)) {
      return 0;
    }
    if (location.startsWith(AppRouter.reportItemPath)) {
      return 1;
    }
    if (location.startsWith(AppRouter.scanQrPath)) {
      return 2;
    }
    if (location.startsWith(AppRouter.notificationsPath)) {
      return 3;
    }
    if (location.startsWith(AppRouter.historyPath)) {
      return 4;
    }
    return 0; // Default ke home jika tidak ada yang cocok
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(AppRouter.homePath);
        break;
      case 1:
        context.goNamed(AppRouter.reportItemPath);
        break;
      case 2:
        context.goNamed(AppRouter.scanQrPath);
        break;
      case 3:
        context.goNamed(AppRouter.notificationsPath);
        break;
      case 4:
        context.goNamed(AppRouter.historyPath);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child, // Konten halaman aktif akan ditampilkan di sini
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        // Warna dan gaya akan diambil dari BottomNavigationBarThemeData di app_themes.dart
        // Anda bisa override di sini jika perlu kustomisasi spesifik
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined), // Ganti dengan ikon 'papan' yang sesuai
            activeIcon: Icon(Icons.add_box),    // atau Icons.assignment_outlined / Icons.post_add
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
            icon: Icon(Icons.history_outlined), // Ganti dengan ikon 'dokumen' yang sesuai
            activeIcon: Icon(Icons.history),    // atau Icons.article_outlined
            label: 'Riwayat',
          ),
        ],
      ),
      // Anda bisa menambahkan FloatingActionButton di sini jika diperlukan untuk halaman tertentu
      // floatingActionButton: selectedIndex == 0 // Contoh: hanya tampil di Beranda
      //     ? FloatingActionButton(
      //         onPressed: () {
      //           // Aksi FAB, misal ke halaman chat list
      //           context.goNamed(AppRouter.chatListPath);
      //         },
      //         child: const Icon(Icons.chat_bubble_outline),
      //       )
      //     : null,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Jika menggunakan FAB dengan notch
    );
  }
}
