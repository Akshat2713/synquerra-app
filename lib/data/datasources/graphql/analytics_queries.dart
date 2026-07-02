/// GraphQL queries related to device analytics.
class AnalyticsQueries {
  AnalyticsQueries._();

  /// Builds the `analyticsDataByImei` query.
  ///
  /// NOTE: despite the field name, this now takes a `deviceId`
  /// (device_master.id), not the device's IMEI.
  static String analyticsByDeviceId({
    required String deviceId,
    int skip = 0,
    int? limit,
    int? dataInterval,
    String? startDate,
    String? endDate,
    bool uniqueLatLong = true,
  }) {
    return '{ analyticsDataByImei('
        'deviceId: "$deviceId"'
        ', skip: $skip'
        '${limit != null ? ', limit: $limit' : ''}'
        '${dataInterval != null ? ', dataInterval: $dataInterval' : ''}'
        '${startDate != null ? ', startDate: "$startDate"' : ''}'
        '${endDate != null ? ', endDate: "$endDate"' : ''}'
        ', uniqueLatLong: $uniqueLatLong'
        ') {id topic imei geoid packet latitude longitude speed battery '
        'signal alert timestamp deviceTimestamp deviceRawTimestamp '
        'rawAlert type rawTemperature rawPhone1 rawPhone2 '
        'rawControlPhone} }';
  }
}
