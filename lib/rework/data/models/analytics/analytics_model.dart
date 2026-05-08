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
  //
  final int? interval;
  final String? alert;
  final String? timestamp;
  final String? deviceRawTimestamp;
  final String? type;
  final String? rawTemperature;
  final String? rawPhone1;
  final String? rawPhone2;
  final String? rawControlPhone;
  final String? rawAlert;

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
    this.interval,
    this.alert,
    this.timestamp,
    this.deviceRawTimestamp,
    this.type,
    this.rawTemperature,
    this.rawPhone1,
    this.rawPhone2,
    this.rawControlPhone,
    this.rawAlert,
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
    interval: json['interval'] as int?,
    alert: json['alert'] as String?,
    timestamp: json['timestamp'] as String?,
    deviceRawTimestamp: json['deviceRawTimestamp'] as String?,
    type: json['type'] as String?,
    rawTemperature: json['rawTemperature'] as String?,
    rawPhone1: json['rawPhone1'] as String?,
    rawPhone2: json['rawPhone2'] as String?,
    rawControlPhone: json['rawControlPhone'] as String?,
    rawAlert: json['rawAlert'] as String?,
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
    interval: interval,
    alert: alert,
    timestamp: timestamp,
    deviceRawTimestamp: deviceRawTimestamp,
    type: type,
    temperature: rawTemperature,
    phone1: rawPhone1,
    phone2: rawPhone2,
    controlPhone: rawControlPhone,
    rawAlert: rawAlert,
    deviceTimestamp: deviceTimestamp,
  );
}
