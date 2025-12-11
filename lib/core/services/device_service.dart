import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_preferences.dart'; // Import your existing UserPreferences

class DeviceService {
  // Replace with your actual base URL
  static const String _baseUrl = 'https://api.synquerra.com';

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
