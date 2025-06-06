
class ServerException implements Exception {
  final String message;
  ServerException({this.message = "An error occurred on the server."});
}

class CacheException implements Exception {
  final String message;
  CacheException({this.message = "An error occurred with local caching."});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({this.message = "A network error occurred."});
}

class AuthException implements Exception { // Definisi AuthException Anda
  final String message;
  AuthException({required this.message}); // Constructor yang benar
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException({this.message = "The requested resource was not found."});
}