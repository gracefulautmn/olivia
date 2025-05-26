// lib/core/errors/exceptions.dart

// Kelas dasar untuk semua custom exceptions di aplikasi
class AppException implements Exception {
  final String message;
  final int? statusCode; // Opsional, untuk error terkait HTTP atau API

  AppException({required this.message, this.statusCode});

  @override
  String toString() {
    String result = 'AppException: $message';
    if (statusCode != null) {
      result += ' (Status Code: $statusCode)';
    }
    return result;
  }
}

// Exception yang dilempar ketika terjadi error di sisi server (misalnya, API error)
class ServerException extends AppException {
  ServerException({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

// Exception yang dilempar ketika terjadi masalah koneksi jaringan
class NetworkException extends AppException {
  NetworkException({String message = "Tidak ada koneksi internet atau server tidak terjangkau."})
      : super(message: message);
}

// Exception yang dilempar ketika terjadi masalah dengan cache lokal
class CacheException extends AppException {
  CacheException({String message = "Gagal mengakses data dari cache."})
      : super(message: message);
}

// Exception yang dilempar ketika input yang diberikan tidak valid
class InvalidInputException extends AppException {
  InvalidInputException({required String message}) : super(message: message);
}

// Exception spesifik untuk masalah autentikasi
class AuthenticationException extends AppException {
  AuthenticationException({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

// Exception yang dilempar ketika resource yang diminta tidak ditemukan
class NotFoundException extends AppException {
  NotFoundException({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

// Exception yang dilempar ketika pengguna tidak memiliki izin
class AuthorizationException extends AppException {
  AuthorizationException({String message = "Anda tidak memiliki izin untuk tindakan ini.", int? statusCode})
      : super(message: message, statusCode: statusCode);
}

// Exception untuk error yang tidak terduga atau tidak terklasifikasi
class UnexpectedException extends AppException {
  UnexpectedException({String message = "Terjadi kesalahan yang tidak terduga."})
      : super(message: message);
}
