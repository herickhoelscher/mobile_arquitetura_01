import 'package:http/http.dart' as http;

class AppHttpClient {
  final http.Client _client;

  AppHttpClient({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> get(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Erro na requisição: ${response.statusCode}');
    }
    return response;
  }
}
