// lib/data/datasources/graphql/device_queries.dart
class DeviceQueries {
  DeviceQueries._();

  /// Device IMEI query
  static const String deviceImeiQuery = '''
    query {
      devices {
        imei
      }
    }
  ''';

  /// Get analytics data by IMEI (using string interpolation - no variables)
  static String getAnalytics(String imei) =>
      '''
    {
      analyticsDataByImei(imei: "$imei") {
        id
        topic
        imei
        interval
        geoid
        packet
        latitude
        longitude
        speed
        battery
        signal
        alert
        timestamp
        deviceTimestamp
        deviceRawTimestamp
        rawPacket
        rawImei
        rawAlert
        type
        rawTemperature
      }
    }
  ''';

  /// Get 24-hour distance data (using string interpolation - no variables)
  static String getDistance(String imei) =>
      '''
    {
      analyticsDistance24(imei: "$imei") {
        hour
        dateHour
        distance
        cumulative
      }
    }
  ''';

  /// Get device health data (using string interpolation - no variables)
  static String getHealth(String imei) =>
      '''
    {
      analyticsHealth(imei: "$imei") {
        gpsScore
        movement
        movementStats
        temperatureHealthIndex
        temperatureStatus
      }
    }
  ''';

  /// Get device uptime data (using string interpolation - no variables)
  static String getUptime(String imei) =>
      '''
    {
      analyticsUptime(imei: "$imei") {
        score
        expectedPackets
        receivedPackets
        largestGapSec
        dropouts
      }
    }
  ''';
}
