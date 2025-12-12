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
    );
  }
}
