import '../../../domain/entities/analytics/analytics_entity.dart';

class AnalyticsModel {
  final String id;
  final String topic;
  final String imei;
  final String? packet;
  final String? latitude;
  final String? longitude;
  final double? speed;
  final String? battery;
  final String? signal;
  final String? geoid;
  final String deviceTimestamp;

  const AnalyticsModel({
    required this.id,
    required this.topic,
    required this.imei,
    this.packet,
    this.latitude,
    this.longitude,
    this.speed,
    this.battery,
    this.signal,
    this.geoid,
    required this.deviceTimestamp,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) => AnalyticsModel(
    id: json['id'] as String,
    topic: json['topic'] as String,
    imei: json['imei'] as String,
    packet: json['packet'] as String?,
    latitude: json['latitude'] as String?,
    longitude: json['longitude'] as String?,
    speed: json['speed'] as double?,
    battery: json['battery'] as String?,
    signal: json['signal'] as String?,
    geoid: json['geoid'] as String?,
    deviceTimestamp: json['deviceTimestamp'] as String,
  );

  AnalyticsEntity toEntity() => AnalyticsEntity(
    id: id,
    topic: topic,
    imei: imei,
    packet: packet,
    latitude: latitude != null ? double.tryParse(latitude!) : null,
    longitude: longitude != null ? double.tryParse(longitude!) : null,
    speed: speed.toString(),
    battery: battery,
    signal: signal,
    geoid: geoid,
    deviceTimestamp: deviceTimestamp,
  );
}
