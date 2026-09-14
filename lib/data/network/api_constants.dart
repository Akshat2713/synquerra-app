class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.synquerra.com/';
  static const String devBaseUrl =
      'https://synquerraapi.devnik.in/'; // ⚠️ DEV ONLY

  static const String signIn = '/api/v1/auth/sign-in';
  static const String signUp = '/api/v1/auth/register-user';
  static const String orgMemberSignIn = '/api/v1/auth/org-member/sign-in';
  static String deleteUser(String userId) => '/api/v1/users/$userId';

  // ── SignUp & Ownership ────────────────────────────
  static const String createPerson = '/api/v1/persons';
  static String linkDevice(String deviceId) =>
      '/api/v1/devices/$deviceId/owner';
  static String deviceAssignments(String personId) =>
      '/api/v1/devices/$personId/assignments';

  // ── Device ────────────────────────────────────────
  static const String devices = '/api/v1/users/devices';
  static String deviceById(String deviceId) => '/api/v1/devices/$deviceId';
  static String deviceList(String personId) =>
      '/api/v1/device-assignments/person/$personId/all-devices';
  static String personDevices(String personId) =>
      '/api/v1/device-assignments/person/$personId/devices';
  static String relationshipList = '/api/v1/users/relationships';

  // ── Alerts & Errors ───────────────────────────────
  static const String alerts = '/api/v1/alerts-errors/user';
  static const String errors = '/api/v1/alerts-errors/errors';
  static String alertsByPerson(String personId) =>
      '/api/v1/alerts-errors/person/$personId';
  static String alertsByDevice(String deviceId) =>
      '/api/v1/alerts-errors/device/alerts?device_id=$deviceId';
  static String acknowledgeAlert(String alertId) =>
      '/api/v1/alerts-errors/$alertId/acknowledge';

  // ── Analytics ─────────────────────────────────────
  static const String analytics = '/api/v1/analytics/device-analytics-query';
  static const String analyticsQuery = '/api/v1/analytics/graphql';

  // ── Relationship ─────────────────────────────────────
  static const String createRelationshipByPhone = '/api/v1/users/search';
  static const String createRelation = '/api/v1/users/relationships';
  static const String createPersonWithRelationship =
      '/api/v1/users/create-with-relationship';
  static String removeRelationship(String relatedUserId) =>
      '/api/v1/users/relationships/$relatedUserId';

  // ── Geofences ─────────────────────────────────────
  // RESTful standard endpoints (Recommended)
  static String geofences(String deviceId) =>
      '/api/v1/geofences/$deviceId'; // GET (list with ?device_id=), POST (create)
  static String geofenceById(int geofenceId) =>
      '/api/v1/geofences/$geofenceId'; // PUT (edit), DELETE
  static const String assignGeofence = '/api/v1/geofences/assign';
  static String geofenceHistory(String deviceId) =>
      '/api/v1/geofences/device/$deviceId/geofence-history';

  // Legacy geofence aliases (also supported by backend)
  // static const String getGeofences = '/api/v1/geofences/list';
  static const String createGeofence = '/api/v1/geofences';
  static String editGeofence(String id) => '/api/v1/geofences/$id';
  static String deleteGeofence(String id) => '/api/v1/geofences/$id';

  // ── Modes ─────────────────────────────────────────
  static const String getModes = '/api/v1/modes/manual'; // List manual modes
  static const String allModes = '/api/v1/modes';
  static const String switchMode = '/api/v1/devices/switch-mode';

  // ── Settings ─────────────────────────────────────────
  static const String getSettings = '/api/v1/device-settings/get';
  static String updatephone(String deviceId) =>
      '/api/v1/device-settings/$deviceId';
  static const String sendQueryCommand =
      '/api/v1/device-settings/send-query-command';

  // ── Realtime (Soketi) ─────────────────────────────
  static const String soketiHost = 'websocket.synquerra.com';
  static const int soketiPort = 443;
  static const String soketiKey = 'synquerra@23';
  static const bool soketiUseTLS = true;

  // ── Timeouts ──────────────────────────────────────
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;

  // ── Retry ─────────────────────────────────────────
  static const int maxRetries = 2;
  static const int retryDelayMs = 800;
}
