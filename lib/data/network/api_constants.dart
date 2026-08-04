class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.synquerra.com/';
  static const String devBaseUrl =
      'https://synquerraapi.devnik.in/'; // ⚠️ DEV ONLY

  // ── Auth ──────────────────────────────────────────
  static const String signIn = 'api/v1/auth/sign-in';

  // ── SignUp ─────────────────────────────────────────
  static const String createPerson = '/api/v1/persons';
  static const String signUp = '/api/v1/auth/sign-up';
  static const String linkDevice = '/api/v1/device-owners';
  // ── Device ────────────────────────────────────────
  static String deviceList(String personId) =>
      '/api/v1/device-assignments/person/$personId/all-devices';

  // ── Alerts ────────────────────────────────────────
  static const String alerts = 'api/v1/device/alerts-errors/alerts';
  static String alertsByPerson(String personId) =>
      '/api/v1/device/alerts-errors/person/$personId';

  // ── Analytics ─────────────────────────────────────
  static const String analytics = 'api/v1/analytics/device-analytics-query';

  // ── Geofences ─────────────────────────────────────
  static const String getGeofences = 'api/v1/device/geofence/list';
  static const String createGeofence = 'api/v1/device/geofence/create';
  static const String deleteGeofence = 'api/v1/device/geofence/delete';
  static const String editGeofence = 'api/v1/device/geofence/edit';

  // ── Modes ─────────────────────────────────────────
  static const String getModes = 'api/v1/device/mode/manual';
  static const String switchMode = 'api/v1/device/switch-mode';

  // ── Timeouts ──────────────────────────────────────
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;

  // ── Retry ─────────────────────────────────────────
  static const int maxRetries = 2;
  static const int retryDelayMs = 800;
}
