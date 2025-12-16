class AnalyticsData {
  final String id;
  final String imei;
  final String packetType; // 'A', 'N', etc.
  final double? latitude;
  final double? longitude;
  final double? speed;
  final String? battery;
  final String? signal;
  final String timestamp;
  final String? alert;
  final String? temperature;

  AnalyticsData({
    required this.id,
    required this.imei,
    required this.packetType,
    this.latitude,
    this.longitude,
    this.speed,
    this.battery,
    this.signal,
    required this.timestamp,
    this.alert,
    this.temperature,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numbers that might come as Strings "23.5" or Doubles 23.5
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return AnalyticsData(
      id: json['id'] ?? '',
      imei: json['imei'] ?? '',
      packetType: json['packet'] ?? 'Unknown',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      speed: parseDouble(json['speed']),
      battery: json['battery']?.toString(),
      signal: json['signal']?.toString(),
      timestamp: json['timestamp'] ?? '',
      alert: json['alert'],
      temperature: json['rawTemperature']?.toString(),
    );
  }
}

// lib/models/telemetry_models.dart

class AnalyticsDistance {
  final String hour;
  final double distance;
  final double cumulative;

  AnalyticsDistance({
    required this.hour,
    required this.distance,
    required this.cumulative,
  });

  factory AnalyticsDistance.fromJson(Map<String, dynamic> json) {
    return AnalyticsDistance(
      hour: json['hour'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      cumulative: (json['cumulative'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AnalyticsHealth {
  final double gpsScore;
  final String temperatureStatus;
  final double temperatureIndex;
  final List<String> movementStats;
  // We can add movement stats later if needed for a chart

  AnalyticsHealth({
    required this.gpsScore,
    required this.temperatureStatus,
    required this.temperatureIndex,
    required this.movementStats,
  });

  factory AnalyticsHealth.fromJson(Map<String, dynamic> json) {
    return AnalyticsHealth(
      gpsScore: (json['gpsScore'] as num?)?.toDouble() ?? 0.0,
      temperatureStatus: json['temperatureStatus'] ?? 'Unknown',
      temperatureIndex:
          (json['temperatureHealthIndex'] as num?)?.toDouble() ?? 0.0,
      movementStats:
          (json['movementStats'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }
}

class AnalyticsUptime {
  final double score;
  final int expected;
  final int received;
  final double largestGap;
  final int dropouts;

  AnalyticsUptime({
    required this.score,
    required this.expected,
    required this.received,
    required this.largestGap,
    required this.dropouts,
  });

  factory AnalyticsUptime.fromJson(Map<String, dynamic> json) {
    return AnalyticsUptime(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      expected: json['expectedPackets'] ?? 0,
      received: json['receivedPackets'] ?? 0,
      largestGap: (json['largestGapSec'] as num?)?.toDouble() ?? 0.0,
      dropouts: json['dropouts'] ?? 0,
    );
  }
}
