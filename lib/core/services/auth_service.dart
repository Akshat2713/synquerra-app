// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../core/models/signup_input.dart';
import '../../core/services/user_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://api.synquerra.com';

  // Returns AuthResponse on success, throws Exception on failure
  // lib/services/auth_service.dart

  Future<AuthResponse> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/signin-query');

    final Map<String, dynamic> body = {
      "query":
          // ADDED 'imei' into the fields list below
          "mutation { signin(input: { email: \"$email\", password: \"$password\" }) { uniqueId firstName lastName imei email mobile tokens { accessToken refreshToken } lastLoginAt message } }",
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['errors'] != null) {
        throw Exception(jsonResponse['errors'][0]['message']);
      }

      final authResponse = AuthResponse.fromJson(jsonResponse);

      if (authResponse.code == 200 && authResponse.status == 'success') {
        // PRO-TIP: Verify the object has an IMEI before returning
        if (authResponse.data?.imei.isEmpty ?? true) {
          print("CRITICAL: Login succeeded but IMEI is still empty from API!");
        }
        return authResponse;
      } else {
        throw Exception(authResponse.message);
      }
    } catch (e) {
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

  Future<List<String>> getDeviceImeis() async {
    final url = Uri.parse('$_baseUrl/device/device-master-query');

    // Get the token to authenticate the request
    final token = await UserPreferences().getAccessToken();

    final Map<String, dynamic> body = {"query": "{ devices { imei } }"};

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Assuming your API needs auth
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        final List<dynamic> devices = jsonResponse['data']['devices'] ?? [];

        // Extract just the IMEIs into a List<String>
        return devices
            .map<String>((device) => device['imei'].toString())
            .toList();
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      print("Error fetching IMEIs: $e");
      return []; // Return empty list on error so app doesn't crash
    }
  }
}
