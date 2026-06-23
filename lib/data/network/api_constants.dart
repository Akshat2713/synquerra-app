class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.synquerra.com/';
  static const String devBaseUrl =
      'https://synquerraapi.devnik.in/'; // ⚠️ DEV ONLY

  // ── Auth ──────────────────────────────────────────
  static const String signIn = 'api/v1/auth/sign-in';
  // static const String signUp = 'api/v1/core/auth/signup';

  // ── SignUp ─────────────────────────────────────────
  static const String createPerson = '/api/v1/person/add';
  static const String signUp = '/api/v1/auth/sign-up';
  static const String linkDevice = '/api/v1/device-owner/claim/serial';
  // ── Device ────────────────────────────────────────
  static const String deviceList = 'api/v1/core/device/list';

  // ── Alerts ────────────────────────────────────────
  static const String alerts = 'api/v1/core/alerts-errors/alerts';
  static const String alertErrors = 'api/v1/core/alerts-errors/device';

  // ── Analytics ─────────────────────────────────────
  static const String analytics = 'api/v1/core/analytics/analytics-query';

  // ── Geofences ─────────────────────────────────────
  static const String getGeofences = 'api/v1/core/geofence/list';
  static const String createGeofence = 'api/v1/core/geofence/create';
  static const String deleteGeofence = 'api/v1/core/geofence/delete';

  // ── Modes ─────────────────────────────────────────
  static const String getModes = 'api/v1/core/mode/list';
  static const String switchMode = 'api/v1/core/device/switch-mode';

  // ── Timeouts ──────────────────────────────────────
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;

  // ── Retry ─────────────────────────────────────────
  static const int maxRetries = 2;
  static const int retryDelayMs = 800;
}
