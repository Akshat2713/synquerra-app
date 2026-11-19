/// GraphQL queries for Schedules.
class ScheduleQuery {
  ScheduleQuery._();

  /// Fetch schedules with optional filters and pagination.
  /// Variables:
  ///   $targetUserId    (String)  - target user ID
  ///   $targetDeviceId  (String)  - target device ID
  ///   $userId          (String)  - user ID
  ///   $deviceId        (String)  - device ID
  ///   $geofenceId      (String)  - geofence ID
  ///   $isActive        (Boolean) - filter active/inactive schedules
  ///   $priority        (String)  - priority level (e.g. HIGH, MEDIUM, LOW)
  ///   $recurrenceType  (String)  - recurrence type (e.g. WEEKLY, CUSTOM)
  ///   $title           (String)  - title search
  ///   $startDateFrom   (String)  - start date range lower bound
  ///   $startDateTo     (String)  - start date range upper bound
  ///   $endDateFrom     (String)  - end date range lower bound
  ///   $endDateTo       (String)  - end date range upper bound
  ///   $dayOfWeek       (Int)     - day index (0 = Sunday, 6 = Saturday)
  ///   $crossesMidnight (Boolean) - filter schedules crossing midnight
  ///   $allowOutside    (Boolean) - filter schedules allowing outside buffer
  ///   $page            (Int)     - optional, pagination
  ///   $limit           (Int)     - optional, pagination
  static const String getSchedules = r'''
    query GetSchedules(
      $userId: String
      $deviceId: String
      $isActive: Boolean
    ) {
      schedules(
        userId: $userId
        deviceId: $deviceId
        isActive: $isActive
      ) {
        id
        title
        description
        targetUser {
          userId
          name
          email
          phone
          role
        }
        device {
          deviceId
          imei
          name
          model
        }
        geofence {
          geofenceId
          name
          type
          coordinates {
            lat
            lng
          }
        }
        startTime
        endTime
        timezone
        recurrenceType
        daysOfWeek
        customDates
        startDate
        endDate
        crossesMidnight
        allowOutside
        priority
        isActive
        graceConfig {
          entryGraceMinutes
          exitGraceMinutes
        }

        createdAt
        updatedAt
      }
    }
  ''';
}

/// Allowed values for schedule priority levels.
class SchedulePriority {
  SchedulePriority._();

  static const String low = 'LOW';
  static const String medium = 'MEDIUM';
  static const String high = 'HIGH';
}

/// Allowed values for schedule recurrence types.
class ScheduleRecurrenceType {
  ScheduleRecurrenceType._();

  static const String daily = 'DAILY';
  static const String weekly = 'WEEKLY';
  static const String custom = 'CUSTOM';
}
