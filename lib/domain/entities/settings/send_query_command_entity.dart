import 'package:equatable/equatable.dart';

class SendQueryCommandEntity extends Equatable {
  final String deviceId;
  final String status;
  final QueryPacketEntity? packet;

  const SendQueryCommandEntity({
    required this.deviceId,
    required this.status,
    this.packet,
  });

  @override
  List<Object?> get props => [deviceId, status, packet];
}

class QueryPacketEntity extends Equatable {
  final String? packet;
  final String? imei;
  final double? latitude;
  final double? longitude;
  final String? speed;
  final String? temperature;
  final DateTime? timestamp;
  final int? battery;
  final int? signal;
  final String? gpsStrength;
  final String? interval;
  final String? geoid;

  const QueryPacketEntity({
    this.packet,
    this.imei,
    this.latitude,
    this.longitude,
    this.speed,
    this.temperature,
    this.timestamp,
    this.battery,
    this.signal,
    this.gpsStrength,
    this.interval,
    this.geoid,
  });

  bool get hasLocation => latitude != null && longitude != null;

  @override
  List<Object?> get props => [
    packet,
    imei,
    latitude,
    longitude,
    speed,
    temperature,
    timestamp,
    battery,
    signal,
    gpsStrength,
    interval,
    geoid,
  ];
}
