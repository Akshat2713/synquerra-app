// lib/data/models/analytics_model.dart
import 'package:equatable/equatable.dart';

class AnalyticsDataModel extends Equatable {
  final String id;
  final String imei;
  final String packetType;
  final String? interval;
  final String? geoid;
  final double? latitude;
  final double? longitude;
  final double? speed;
  final int? battery;
  final int? signal;
  final DateTime timestamp;
  final String? alert;
  final int? temperature;

  const AnalyticsDataModel({
    required this.id,
    required this.imei,
    required this.packetType,
    this.interval,
    this.geoid,
    this.latitude,
    this.longitude,
    this.speed,
    this.battery,
    this.signal,
    required this.timestamp,
    this.alert,
    this.temperature,
  });

  @override
  List<Object?> get props => [
    id,
    imei,
    packetType,
    interval,
    geoid,
    latitude,
    longitude,
    speed,
    battery,
    signal,
    timestamp,
    alert,
    temperature,
  ];
}

class AnalyticsDistanceModel extends Equatable {
  final String hour;
  final double distance;
  final double cumulative;

  const AnalyticsDistanceModel({
    required this.hour,
    required this.distance,
    required this.cumulative,
  });

  @override
  List<Object?> get props => [hour, distance, cumulative];
}

class AnalyticsHealthModel extends Equatable {
  final double gpsScore;
  final String temperatureStatus;
  final double temperatureIndex;
  final List<String> movementStats;

  const AnalyticsHealthModel({
    required this.gpsScore,
    required this.temperatureStatus,
    required this.temperatureIndex,
    required this.movementStats,
  });

  @override
  List<Object?> get props => [
    gpsScore,
    temperatureStatus,
    temperatureIndex,
    movementStats,
  ];
}

class AnalyticsUptimeModel extends Equatable {
  final double score;
  final int expected;
  final int received;
  final double largestGap;
  final int dropouts;

  const AnalyticsUptimeModel({
    required this.score,
    required this.expected,
    required this.received,
    required this.largestGap,
    required this.dropouts,
  });

  @override
  List<Object?> get props => [score, expected, received, largestGap, dropouts];
}
