class DeviceQueries {
  static const String getImeis = '{ devices { imei } }';

  static String getAnalytics(String imei) =>
      '''
    { 
      analyticsDataByImei(imei: "$imei") { 
        id topic imei interval geoid packet latitude longitude 
        speed battery signal alert timestamp deviceTimestamp 
        deviceRawTimestamp rawPacket rawImei rawAlert type rawTemperature 
      } 
    }
  ''';

  static String getDistance(String imei) =>
      '''
    { 
      analyticsDistance24(imei: "$imei") { 
        hour dateHour distance cumulative 
      } 
    }
  ''';

  static String getHealth(String imei) =>
      '''
    { 
      analyticsHealth(imei: "$imei") { 
        gpsScore movement movementStats temperatureHealthIndex temperatureStatus 
      } 
    }
  ''';

  static String getUptime(String imei) =>
      '''
    { 
      analyticsUptime(imei: "$imei") { 
        score expectedPackets receivedPackets largestGapSec dropouts 
      } 
    }
  ''';
}
