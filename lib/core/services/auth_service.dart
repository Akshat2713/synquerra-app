// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  static const String _baseUrl = 'https://api.synquerra.com';

  // Returns AuthResponse on success, throws Exception on failure
  Future<AuthResponse> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/signin-query');

    // Constructing the GraphQL query payload
    final Map<String, dynamic> body = {
      "query":
          "mutation { signin(input: { email: \"$email\", password: \"$password\" }) { uniqueId firstName lastName email mobile tokens { accessToken refreshToken } lastLoginAt message } }",
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // Decode the raw response
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Check if the API returned a structured error (sometimes 200 OK contains errors in GraphQL)
      if (jsonResponse['errors'] != null) {
        throw Exception(jsonResponse['errors'][0]['message']);
      }

      // Parse into our model
      final authResponse = AuthResponse.fromJson(jsonResponse);

      if (authResponse.code == 200 && authResponse.status == 'success') {
        return authResponse;
      } else {
        throw Exception(authResponse.message);
      }
    } catch (e) {
      // Re-throw so the UI can handle the error message
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
