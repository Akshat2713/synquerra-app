// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../core/models/signup_input.dart';

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

  Future<SignupResponse> signup(SignupInput input) async {
    final url = Uri.parse('$_baseUrl/auth/signup-query');

    // Using Triple Quotes (""") makes the GraphQL string much easier to read
    // and handles the inner quotes automatically.
    String mutation =
        """
      mutation {
        signup(input: {
          firstName: "${input.firstName}",
          middleName: "${input.middleName}",
          lastName: "${input.lastName}",
          email: "${input.email}",
          mobile: "${input.mobile}",
          password: "${input.password}"
        }) {
          status
          data {
            user {
              _id
              name
              email
            }
          }
        }
      }
    """;

    final Map<String, dynamic> body = {"query": mutation};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // 1. Check for API-level errors (e.g. "Email already exists")
      if (jsonResponse['errors'] != null) {
        throw Exception(jsonResponse['errors'][0]['message']);
      }

      // 2. Parse using the shared model we created
      return SignupResponse.fromJson(jsonResponse);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
