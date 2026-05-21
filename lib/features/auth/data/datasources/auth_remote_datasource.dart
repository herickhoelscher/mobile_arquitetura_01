import 'dart:convert';
import '../../../../core/network/http_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final AppHttpClient httpClient;
  static const _baseUrl = 'https://dummyjson.com';

  AuthRemoteDatasource({required this.httpClient});

  Future<UserModel> login(String username, String password) async {
    try {
      final response = await httpClient.post(
        '$_baseUrl/auth/login',
        {'username': username, 'password': password, 'expiresInMins': 60},
      );
      return UserModel.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } on ServerException {
      throw AuthException('Usuário ou senha inválidos.');
    }
  }

  Future<UserModel> getProfile(String token) async {
    final response = await httpClient.getWithAuth('$_baseUrl/auth/me', token);
    final data = json.decode(response.body) as Map<String, dynamic>;
    // /auth/me não retorna accessToken; injetamos para reutilizar UserModel
    data['accessToken'] = token;
    data['refreshToken'] = '';
    return UserModel.fromJson(data);
  }
}
