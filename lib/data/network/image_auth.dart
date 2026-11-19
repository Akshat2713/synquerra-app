import 'api_constants.dart';

class ImageAuth {
  ImageAuth._();

  static String? _token;

  static void setToken(String? token) => _token = token;

  static Map<String, String>? headersFor(String url) {
    final token = _token;
    if (token == null || token.isEmpty) return null;
    final host = Uri.tryParse(url)?.host;
    if (host != Uri.parse(ApiConstants.baseUrl).host) return null;
    return {'Authorization': 'Bearer $token'};
  }
}
