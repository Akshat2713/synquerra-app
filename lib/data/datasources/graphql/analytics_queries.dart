/// GraphQL queries related to device analytics.
class AnalyticsQueries {
  AnalyticsQueries._();

  /// Builds the `analyticsDataByDeviceId` query matching the exact selection set.
  static String analyticsByDeviceId({
    required String deviceId,
    int skip = 0,
    int? limit,
    int? dataInterval,
    String? startDate,
    String? endDate,
  }) {
    return '''
      query {
        analyticsDataByDeviceId(
          deviceId: "$deviceId",
          skip: $skip
          ${limit != null ? ', limit: $limit' : ''}
          ${dataInterval != null ? ', dataInterval: $dataInterval' : ''}
          ${startDate != null ? ', startDate: "$startDate"' : ''}
          ${endDate != null ? ', endDate: "$endDate"' : ''}
          
        ) {
          id
          imei
          geoid
          packet
          latitude
          longitude
          speed
          battery
          signal
          deviceTimestamp
          type
          geofence {
            geofence_name
            geofence_number
            geofence_id
          }
          address {
            address
          }
          mode {
            name
          }
        }
      }
    ''';
  }
}
