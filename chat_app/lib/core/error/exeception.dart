
class ServerExceptions implements Exception {}
class CacheExceptions implements Exception {}
class NetworkException implements Exception {}
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}