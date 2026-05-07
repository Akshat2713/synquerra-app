import 'package:equatable/equatable.dart';

class DeviceEntity extends Equatable {
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

  const DeviceEntity({
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

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasData => battery != null && signal != null;

  @override
  List<Object?> get props => [
    topic,
    imei,
    interval,
    geoid,
    packet,
    latitude,
    longitude,
    speed,
    temperature,
    currentMode,
    ledStatus,
    timestamp,
    battery,
    signal,
    gpsStrength,
    studentName,
    studentId,
    isActive,
    isSubscribed,
    createdAt,
    updatedAt,
  ];
}
