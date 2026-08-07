class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.synquerra.com/';
  static const String devBaseUrl =
      'https://synquerraapi.devnik.in/'; // ⚠️ DEV ONLY

  static const String signIn = '/api/v1/auth/sign-in';
  static const String signUp = '/api/v1/auth/sign-up';
  static const String orgMemberSignIn = '/api/v1/auth/org-member/sign-in';

  // ── SignUp & Ownership ────────────────────────────
  static const String createPerson = '/api/v1/persons';
  static const String linkDevice = '/api/v1/device-owners';
  static const String assignDevice = '/api/v1/device-assignments';

  // ── Device ────────────────────────────────────────
  static const String devices = '/api/v1/devices';
  static String deviceById(String deviceId) => '/api/v1/devices/$deviceId';
  static String deviceList(String personId) =>
      '/api/v1/device-assignments/person/$personId/all-devices';
  static String personDevices(String personId) =>
      '/api/v1/device-assignments/person/$personId/devices';

  // ── Alerts & Errors ───────────────────────────────
  static const String alerts = '/api/v1/alerts-errors/alerts';
  static const String errors = '/api/v1/alerts-errors/errors';
  static String alertsByPerson(String personId) =>
      '/api/v1/alerts-errors/person/$personId';
  static String alertsByDevice(String deviceId) =>
      '/api/v1/alerts-errors/device?device_id=$deviceId';
  static String acknowledgeAlert(String alertId) =>
      '/api/v1/alerts-errors/$alertId/acknowledge';

  // ── Analytics ─────────────────────────────────────
  static const String analytics = '/api/v1/analytics/device-analytics-query';
  static const String analyticsQuery = '/api/v1/analytics';

  // ── Geofences ─────────────────────────────────────
  // RESTful standard endpoints (Recommended)
  static const String geofences =
      '/api/v1/geofences'; // GET (list with ?device_id=), POST (create)
  static String geofenceById(int geofenceId) =>
      '/api/v1/geofences/$geofenceId'; // PUT (edit), DELETE
  static const String assignGeofence = '/api/v1/geofences/assign';
  static String geofenceHistory(String deviceId) =>
      '/api/v1/geofences/device/$deviceId/geofence-history';

  // Legacy geofence aliases (also supported by backend)
  static const String getGeofences = '/api/v1/geofences/list';
  static const String createGeofence = '/api/v1/geofences/create';
  static const String editGeofence = '/api/v1/geofences/edit';
  static const String deleteGeofence = '/api/v1/geofences/delete';

  // ── Modes ─────────────────────────────────────────
  static const String getModes = '/api/v1/modes/manual'; // List manual modes
  static const String allModes = '/api/v1/modes';
  static const String switchMode = '/api/v1/devices/switch-mode';

  // ── Settings ─────────────────────────────────────────
  static const String getSettings = '/api/v1/device-settings/get';
  static const String updatephone = '/api/v1/device-settings/update-core';

  // ── Timeouts ──────────────────────────────────────
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;

  // ── Retry ─────────────────────────────────────────
  static const int maxRetries = 2;
  static const int retryDelayMs = 800;
}
