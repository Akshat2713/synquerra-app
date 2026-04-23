// lib/business/entities/analytics_entity.dart
import 'package:equatable/equatable.dart';

class AnalyticsDataEntity extends Equatable {
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

  const AnalyticsDataEntity({
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

  bool get hasValidLocation =>
      latitude != null &&
      longitude != null &&
      !(latitude == 0 && longitude == 0);

  bool get isOnline =>
      timestamp.isAfter(DateTime.now().subtract(const Duration(minutes: 5)));

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

class AnalyticsDistanceEntity extends Equatable {
  final String hour;
  final double distance;
  final double cumulative;

  const AnalyticsDistanceEntity({
    required this.hour,
    required this.distance,
    required this.cumulative,
  });

  bool get isIdle => distance == 0;

  @override
  List<Object?> get props => [hour, distance, cumulative];
}

class AnalyticsHealthEntity extends Equatable {
  final double gpsScore;
  final String temperatureStatus;
  final double temperatureIndex;
  final List<String> movementStats;

  const AnalyticsHealthEntity({
    required this.gpsScore,
    required this.temperatureStatus,
    required this.temperatureIndex,
    required this.movementStats,
  });

  bool get isNormal => temperatureStatus.toLowerCase() == 'normal';

  @override
  List<Object?> get props => [
    gpsScore,
    temperatureStatus,
    temperatureIndex,
    movementStats,
  ];
}

class AnalyticsUptimeEntity extends Equatable {
  final double score;
  final int expected;
  final int received;
  final double largestGap;
  final int dropouts;

  const AnalyticsUptimeEntity({
    required this.score,
    required this.expected,
    required this.received,
    required this.largestGap,
    required this.dropouts,
  });

  int get loss => expected - received;

  double get lossPercent => expected > 0 ? (loss / expected * 100) : 0;

  bool get hasHighLoss => lossPercent > 10;

  @override
  List<Object?> get props => [score, expected, received, largestGap, dropouts];
}
