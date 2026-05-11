import 'package:equatable/equatable.dart';

class AnalyticsEntity extends Equatable {
  final String id;
  final String topic;
  final String imei;
  final String? packet;
  final double? latitude;
  final double? longitude;
  final String? speed;
  final String? battery;
  final String? signal;
  final String? geoid;
  final int? interval;
  final String? alert;
  final String? timestamp;
  final String? deviceRawTimestamp;
  final String? type;
  final String? temperature;
  final String? phone1;
  final String? phone2;
  final String? controlPhone;
  final String? rawAlert;
  final String deviceTimestamp;

  const AnalyticsEntity({
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
    this.temperature,
    this.phone1,
    this.phone2,
    this.controlPhone,
    this.rawAlert,
    required this.deviceTimestamp,
  });

  bool get hasLocation => latitude != null && longitude != null;

  @override
  List<Object?> get props => [
    id,
    topic,
    imei,
    packet,
    latitude,
    longitude,
    speed,
    battery,
    signal,
    geoid,
    interval,
    alert,
    timestamp,
    deviceRawTimestamp,
    type,
    temperature,
    phone1,
    phone2,
    controlPhone,
    rawAlert,
    deviceTimestamp,
  ];
}
