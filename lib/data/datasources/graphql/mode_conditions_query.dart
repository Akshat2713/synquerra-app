/// GraphQL queries for Mode Conditions.
class ModeConditionsQuery {
  ModeConditionsQuery._();

  /// Fetch mode conditions for a device.
  /// Variables:
  ///   $deviceId      (String)  - device id
  ///   $conditionType (String)  - speed | battery | geofence
  ///   $enabled       (Boolean) - only enabled conditions
  ///   $scope         (String)  - e.g. "device"
  ///   $page          (Int)     - optional, pagination
  ///   $limit         (Int)     - optional, pagination
  static const String getModeConditions = r'''
    query ModeConditions(
      $deviceId: String
      $conditionType: String
      $enabled: Boolean
      $scope: String
      $page: Int
      $limit: Int
    ) {
      modeConditions(
        deviceId: $deviceId
        conditionType: $conditionType
        enabled: $enabled
        scope: $scope
        page: $page
        limit: $limit
      ) {
        id
        modeId
        deviceId
        conditionType
        config
        enabled
        mode {
          id
          modeId
          name
          description
          priority
        }
        createdAt
        updatedAt
      }
    }
  ''';
}

/// Allowed values for the `conditionType` variable.
class ModeConditionType {
  ModeConditionType._();

  // static const String speed = 'speed';
  // static const String battery = 'battery';
  static const String geofence = 'geofence';
  static const String deviceGeofence = 'device_geofence';
}
