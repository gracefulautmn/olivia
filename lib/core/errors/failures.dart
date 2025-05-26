// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

// Kelas dasar abstrak untuk semua jenis kegagalan (Failure)
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode; // Opsional, untuk kegagalan terkait HTTP

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// Kegagalan Umum

// Kegagalan yang disebabkan oleh masalah server (misalnya, error 500, 404 dari API)
class ServerFailure extends Failure {
  const ServerFailure({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

// Kegagalan yang disebabkan oleh masalah koneksi jaringan
class NetworkFailure extends Failure {
  const NetworkFailure({String message = "Tidak ada koneksi internet. Periksa jaringan Anda."})
      : super(message: message);
}

// Kegagalan yang disebabkan oleh masalah cache (misalnya, data tidak ditemukan di cache)
class CacheFailure extends Failure {
  const CacheFailure({String message = "Gagal mengambil data dari cache."})
      : super(message: message);
}

// Kegagalan yang disebabkan oleh input yang tidak valid
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({required String message}) : super(message: message);
}

// Kegagalan Spesifik Aplikasi (Contoh)

// Kegagalan terkait autentikasi
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

// Kegagalan karena izin ditolak (Unauthorized / Forbidden)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({String message = "Anda tidak memiliki izin untuk melakukan tindakan ini.", int? statusCode})
      : super(message: message, statusCode: statusCode);
}

// Kegagalan ketika data yang diharapkan tidak ditemukan
class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

// Kegagalan kustom lainnya bisa ditambahkan di sini sesuai kebutuhan
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({String message = "Terjadi kesalahan yang tidak terduga."})
      : super(message: message);
}

// Helper function untuk mengubah Exception menjadi Failure
// Ini bisa ditempatkan di sini atau di dalam implementasi repository
// jika lebih spesifik.
// Failure handleException(Exception exception) {
//   if (exception is DioError) { // Jika menggunakan Dio untuk HTTP
//     if (exception.type == DioErrorType.connectTimeout ||
//         exception.type == DioErrorType.sendTimeout ||
//         exception.type == DioErrorType.receiveTimeout ||
//         exception.type == DioErrorType.other && exception.error is SocketException) {
//       return NetworkFailure();
//     } else if (exception.response != null) {
//       // Handle status code dari server
//       if (exception.response!.statusCode == 401) {
//         return AuthenticationFailure(message: "Sesi berakhir atau kredensial tidak valid.", statusCode: 401);
//       } else if (exception.response!.statusCode == 403) {
//         return AuthorizationFailure(statusCode: 403);
//       } else if (exception.response!.statusCode == 404) {
//         return NotFoundFailure(message: "Data tidak ditemukan.", statusCode: 404);
//       }
//       return ServerFailure(message: exception.response?.data?['message'] ?? "Kesalahan Server", statusCode: exception.response?.statusCode);
//     }
//   } else if (exception is SupabaseAuthException) { // Contoh untuk Supabase Auth
//       return AuthenticationFailure(message: exception.message, statusCode: int.tryParse(exception.statusCode ?? ""));
//   } else if (exception is PostgrestException) { // Contoh untuk Supabase Postgrest
//       return ServerFailure(message: exception.message, statusCode: int.tryParse(exception.code ?? ""));
//   }
//   return UnexpectedFailure(message: exception.toString());
// }
