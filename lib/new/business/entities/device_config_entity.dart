// lib/business/entities/device_config_entity.dart
import 'package:equatable/equatable.dart';

class DeviceIntervalsEntity extends Equatable {
  final int normalSendingInterval;
  final int sosSendingInterval;
  final int normalScanningInterval;
  final int airplaneInterval;

  const DeviceIntervalsEntity({
    required this.normalSendingInterval,
    required this.sosSendingInterval,
    required this.normalScanningInterval,
    required this.airplaneInterval,
  });

  @override
  List<Object?> get props => [
    normalSendingInterval,
    sosSendingInterval,
    normalScanningInterval,
    airplaneInterval,
  ];
}

class DeviceLimitsEntity extends Equatable {
  final double temperatureLimit;
  final double speedLimit;
  final int lowBatteryLimit;

  const DeviceLimitsEntity({
    required this.temperatureLimit,
    required this.speedLimit,
    required this.lowBatteryLimit,
  });

  @override
  List<Object?> get props => [temperatureLimit, speedLimit, lowBatteryLimit];
}
