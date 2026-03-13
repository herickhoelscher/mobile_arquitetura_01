import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/app_exception.dart';

class AppHttpClient {
  final http.Client _client;

  AppHttpClient({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> get(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return response;
      throw ServerException();
    } on SocketException {
      throw NetworkException();
    } on HttpException {
      throw NetworkException();
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException();
    }
  }
}
