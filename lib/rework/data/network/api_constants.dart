class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.synquerra.com/';
  static const String devBaseUrl =
      'https://synquerraapi.devnik.in/'; // ⚠️ DEV ONLY

  // ── Auth ──────────────────────────────────────────
  static const String signIn = 'auth/signin';
  static const String signUp = 'auth/signup';

  // ── Device ────────────────────────────────────────
  static const String deviceList = 'device/list';

  // ── Alerts ────────────────────────────────────────
  static const String alerts = 'alerts-errors/alerts';
  static const String alertErrors = 'alerts-errors/device';

  // ── Analytics ─────────────────────────────────────
  static const String analytics = 'analytics/analytics-query';

  // ── Geofences ─────────────────────────────────────
  static const String getGeofences = 'geofence/list';
  static const String createGeofence = 'geofence/create';
  static const String deleteGeofence = 'geofence/delete';

  // ── Modes ─────────────────────────────────────────
  static const String getModes = '/mode/list';
  static const String switchMode = '/device/switch-mode';

  // ── Timeouts ──────────────────────────────────────
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;

  // ── Retry ─────────────────────────────────────────
  static const int maxRetries = 2;
  static const int retryDelayMs = 800;
}
