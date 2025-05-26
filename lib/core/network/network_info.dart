// lib/core/network/network_info.dart

import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// Interface untuk NetworkInfo
abstract class NetworkInfo {
  /// Memeriksa apakah perangkat terhubung ke internet.
  Future<bool> get isConnected;
}

// Implementasi NetworkInfo menggunakan package internet_connection_checker_plus
@LazySingleton(as: NetworkInfo) // Daftarkan sebagai implementasi dari NetworkInfo
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionCheckerPlus connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    // Pengecekan koneksi bisa memakan waktu, jadi pastikan ini async
    // dan mungkin perlu di-handle dengan loading indicator di UI jika
    // pengecekan dilakukan sebelum operasi yang sangat krusial.
    // Untuk repository, ini akan berjalan di background.
    return await connectionChecker.hasConnection;
  }
}

// (Opsional) Module untuk mendaftarkan InternetConnectionCheckerPlus ke GetIt
// jika Anda tidak ingin meng-inject-nya langsung ke NetworkInfoImpl
// melalui konstruktor dari tempat lain (misalnya, dari $initGetIt jika injectable
// bisa meng-handle dependensi eksternal seperti ini secara otomatis atau via module).
// Jika injectable tidak otomatis menangani InternetConnectionCheckerPlus,
// Anda perlu mendaftarkannya di di_container.dart menggunakan @module.

// Contoh @module di di_container.dart jika diperlukan:
// @module
// abstract class ThirdPartyInjectableModule {
//   @lazySingleton
//   InternetConnectionCheckerPlus get internetConnectionChecker => InternetConnectionCheckerPlus();
// }
// Kemudian NetworkInfoImpl akan bisa di-inject dengan:
// NetworkInfoImpl(this.connectionChecker); -> injectable akan resolve InternetConnectionCheckerPlus
