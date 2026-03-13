class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException() : super('Sem conexão com a internet.');
}

class ServerException extends AppException {
  ServerException() : super('Erro ao buscar dados do servidor.');
}

class CacheException extends AppException {
  CacheException() : super('Nenhum dado em cache disponível.');
}
