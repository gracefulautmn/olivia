// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider
import 'package:olivia/core/di/service_locator.dart'; // Ganti dengan path Anda
import 'package:olivia/core/utils/app_colors.dart'; // Ganti dengan path Anda
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart'; // Ganti dengan path Anda
import 'package:olivia/navigation/app_router.dart'; // Ganti dengan path Anda

class LostAndFoundApp extends StatelessWidget {
  const LostAndFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(); // Instance router Anda

    // Sediakan AuthBloc di sini agar tersedia untuk seluruh aplikasi
    // Ini sangat umum untuk AuthBloc karena status login memengaruhi banyak bagian.
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>()..add(const AuthCheckStatusRequested()), // Ambil dari GetIt dan langsung cek status
      child: MaterialApp.router(
        title: 'OLIVIA', // Ganti dengan nama aplikasi Anda
        theme: ThemeData(
          primarySwatch: AppColors.primaryMaterialColor,
          scaffoldBackgroundColor: AppColors.backgroundColor,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.primaryColor,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          // Tambahkan konfigurasi tema lainnya
        ),
        routerConfig: appRouter.config(), // Gunakan routerConfig
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}