// lib/data/network/api_constants.dart
class ApiConstants {
  ApiConstants._(); // Prevent instantiation

  // Base URL - should be configured per environment
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.synquerra.com',
  );

  // Endpoints
  static const String authSignin = '/auth/signin-query';
  static const String authSignup = '/auth/signup-query';
  static const String deviceMaster = '/device/device-master-query';
  static const String analytics = '/analytics/analytics-query';
  static const String sendCommand = '/send';

  // Timeouts (in seconds)
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  // Retry configuration
  static const int maxRetries = 3;
  static const int retryDelayMs = 1000;
}
