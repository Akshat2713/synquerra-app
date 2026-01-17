import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseApiService {
  static const String baseUrl = 'https://api.synquerra.com';
  final String? _token;

  BaseApiService(this._token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
  }
}
