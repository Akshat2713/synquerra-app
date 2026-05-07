import '../../../domain/entities/device/device_entity.dart';

class DeviceModel {
  final String topic;
  final String imei;
  final int interval;
  final String geoid;
  final String? packet;
  final String? latitude;
  final String? longitude;
  final String? speed;
  final String? temperature;
  final String currentMode;
  final String ledStatus;
  final String? timestamp;
  final String? battery;
  final String? signal;
  final String? gpsStrength;
  final String studentName;
  final String studentId;
  final bool isActive;
  final bool isSubscribed;
  final String createdAt;
  final String updatedAt;

  const DeviceModel({
    required this.topic,
    required this.imei,
    required this.interval,
    required this.geoid,
    this.packet,
    this.latitude,
    this.longitude,
    this.speed,
    this.temperature,
    required this.currentMode,
    required this.ledStatus,
    this.timestamp,
    this.battery,
    this.signal,
    this.gpsStrength,
    required this.studentName,
    required this.studentId,
    required this.isActive,
    required this.isSubscribed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
    topic: json['topic'] as String,
    imei: json['imei'] as String,
    interval: json['interval'] as int,
    geoid: json['geoid'] as String,
    packet: json['packet'] as String?,
    latitude: json['latitude'] as String?,
    longitude: json['longitude'] as String?,
    speed: json['speed'] as String?,
    temperature: json['temperature'] as String?,
    currentMode: json['current_mode'] as String,
    ledStatus: json['led_status'] as String,
    timestamp: json['timestamp'] as String?,
    battery: json['battery'] as String?,
    signal: json['signal'] as String?,
    gpsStrength: json['gps_strength'] as String?,
    studentName: json['student_name'] as String,
    studentId: json['student_id'] as String,
    isActive: json['is_active'] as bool,
    isSubscribed: json['is_subscribed'] as bool,
    createdAt: json['createdAt'] as String,
    updatedAt: json['updatedAt'] as String,
  );

  DeviceEntity toEntity() => DeviceEntity(
    topic: topic,
    imei: imei,
    interval: interval,
    geoid: geoid,
    packet: packet,
    latitude: latitude,
    longitude: longitude,
    speed: speed,
    temperature: temperature,
    currentMode: currentMode,
    ledStatus: ledStatus,
    timestamp: timestamp,
    battery: battery,
    signal: signal,
    gpsStrength: gpsStrength,
    studentName: studentName,
    studentId: studentId,
    isActive: isActive,
    isSubscribed: isSubscribed,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
