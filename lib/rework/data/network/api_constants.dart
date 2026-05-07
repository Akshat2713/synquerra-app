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

  // ── Analytics ─────────────────────────────────────
  static const String analytics = 'analytics/analytics-query';

  // ── Timeouts ──────────────────────────────────────
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;

  // ── Retry ─────────────────────────────────────────
  static const int maxRetries = 2;
  static const int retryDelayMs = 800;
}
