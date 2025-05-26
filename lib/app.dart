// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/core/config/app_themes.dart';
import 'package:olivia/di_container.dart';
import 'package:olivia/features/auth/presentation/cubit_or_bloc/auth_cubit.dart';
import 'package:olivia/routes.dart'; // Akan kita buat nanti

class LostAndFoundApp extends StatelessWidget {
  const LostAndFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita akan menggunakan MultiBlocProvider di sini jika ada BLoC/Cubit global
    // seperti AuthCubit yang perlu diakses dari berbagai bagian aplikasi.
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => sl<AuthCubit>()..checkAuthStatus(),
          // ..checkAuthStatus() akan dipanggil saat AuthCubit dibuat
          // untuk memeriksa status autentikasi pengguna saat aplikasi dimulai.
        ),
        // Tambahkan BLoC/Cubit global lainnya di sini jika ada
      ],
      child: MaterialApp.router(
        title: 'Lost & Found UP',
        debugShowCheckedModeBanner: false, // Matikan banner debug
        theme: AppThemes.lightTheme, // Tema terang (akan kita definisikan)
        // darkTheme: AppThemes.darkTheme, // Opsional: Tema gelap
        // themeMode: ThemeMode.system, // Opsional: Mengikuti tema sistem

        // Menggunakan GoRouter untuk navigasi
        routerConfig: AppRouter.router,
      ),
    );
  }
}
