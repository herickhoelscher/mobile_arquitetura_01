import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/app_exception.dart';

class AppHttpClient {
  final http.Client _client;

  AppHttpClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

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

  Future<http.Response> getWithAuth(String url, String token) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: _authHeaders(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return response;
      if (response.statusCode == 401) {
        throw AuthException('Sessão expirada. Faça login novamente.');
      }
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

  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      }
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

  Future<http.Response> put(String url, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      }
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

  Future<http.Response> delete(String url) async {
    try {
      final response = await _client
          .delete(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response;
      }
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
