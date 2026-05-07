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
    deviceTimestamp,
  ];
}
