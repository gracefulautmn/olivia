// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olivia/app.dart';
import 'package:olivia/core/config/app_constants.dart';
import 'package:olivia/di_container.dart' as di; // Dependency Injection
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:olivia/core/utils/simple_bloc_observer.dart';

Future<void> main() async {
  // Pastikan Flutter binding sudah terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    // authFlowType: AuthFlowType.pkce, // Direkomendasikan untuk mobile apps
  );

  // Inisialisasi Dependency Injection (GetIt dengan Injectable)
  // Menggunakan fungsi baru dari di_container.dart
  await di.configureDependencies();

  // (Opsional) Atur BLoC Observer untuk logging
  Bloc.observer = SimpleBlocObserver();

  // Jalankan aplikasi
  runApp(const LostAndFoundApp());
}
