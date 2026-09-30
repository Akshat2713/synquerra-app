import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../presentation/utils/date_time_formatter.dart';

class AnalyticsQueryModel {
  final String id;
  final String imei;
  final String? packet;
  final String? geoid;
  final String? latitude;
  final String? longitude;
  final String? speed; // raw, e.g. "6 km/hr"
  final String? temperature; // raw, e.g. "35.76 c"
  final String? battery;
  final String? signal;
  final String? gpsStrength; // e.g. "21dB-Hz" (not in entity)
  final String? interval; // e.g. "180" (not in entity)
  final String deviceTimestamp; // UTC, e.g. "2026-09-29T05:44:01"

  const AnalyticsQueryModel({
    required this.id,
    required this.imei,
    this.packet,
    this.geoid,
    this.latitude,
    this.longitude,
    this.speed,
    this.temperature,
    this.battery,
    this.signal,
    this.gpsStrength,
    this.interval,
    required this.deviceTimestamp,
  });

  /// Parses the full API response:
  /// { status, code, data: { device_id, packet: { ... } } }
  factory AnalyticsQueryModel.fromApiResponse(Map<String, dynamic> response) {
    final data = (response['data'] as Map<String, dynamic>?) ?? {};
    final packet = (data['packet'] as Map<String, dynamic>?) ?? {};

    return AnalyticsQueryModel.fromJson(
      packet,
      deviceId: data['device_id']?.toString(),
    );
  }

  /// Parses only the inner "packet" object.
  factory AnalyticsQueryModel.fromJson(
    Map<String, dynamic> json, {
    String? deviceId,
  }) {
    final imei = (json['imei'] ?? '').toString();

    return AnalyticsQueryModel(
      id: deviceId ?? imei,
      imei: imei,
      packet: _str(json['packet']),
      geoid: _str(json['Geoid']),
      latitude: _str(json['latitude']),
      longitude: _str(json['longitude']),
      speed: _str(json['speed']),
      temperature: _str(json['temperature']),
      battery: _str(json['Battery']),
      signal: _str(json['Signal']),
      gpsStrength: _str(json['GPSStrength']),
      interval: _str(json['interval']),
      deviceTimestamp: _str(json['timestamp']) ?? '',
    );
  }

  AnalyticsEntity toEntity() => AnalyticsEntity(
    id: id,
    imei: imei,
    geoid: geoid,
    packet: packet,
    latitude: _num(latitude),
    longitude: _num(longitude),
    speed: _num(speed),
    battery: _num(battery)?.round(),
    signal: _num(signal)?.round(),
    temperature: temperature ?? "NA",
    phone1: "No Primary Number",
    phone2: "No Secondary Number",
    alert: null,
    deviceTimestamp: DateTimeFormatter.parseUtcToLocal(deviceTimestamp),
    type: null,
    geofenceName: null,
    formattedAddress: null,
  );

  // ---------- Helpers ----------

  /// Returns null for null, empty, or "Null"/"null" values.
  static String? _str(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  /// Extracts the first number from strings like "6 km/hr" or "23.294739".
  static double? _num(String? value) {
    if (value == null) return null;
    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(value);
    return match == null ? null : double.tryParse(match.group(0)!);
  }
}
