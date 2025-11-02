class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class AIException implements Exception {
  final String message;
  AIException(this.message);
}

class ConfigException implements Exception {
  final String message;
  ConfigException(this.message);
}