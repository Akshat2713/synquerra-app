// domain/entities/mode/mode_entity.dart
import 'package:equatable/equatable.dart';

class ModeEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final int normalSendingInterval;
  final int sosSendingInterval;
  final int normalScanningInterval;
  final int airplaneInterval;
  final double temperatureLimit;
  final double speedLimit;
  final int lowbatLimit;
  final bool isSystemMode;
  final bool allowUserConditions;
  final int priority;
  final int watchTime;
  final String createdAt;
  final String updatedAt;

  const ModeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.normalSendingInterval,
    required this.sosSendingInterval,
    required this.normalScanningInterval,
    required this.airplaneInterval,
    required this.temperatureLimit,
    required this.speedLimit,
    required this.lowbatLimit,
    required this.isSystemMode,
    required this.allowUserConditions,
    required this.priority,
    required this.watchTime,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    normalSendingInterval,
    sosSendingInterval,
    normalScanningInterval,
    airplaneInterval,
    temperatureLimit,
    speedLimit,
    lowbatLimit,
    isSystemMode,
    allowUserConditions,
    priority,
    watchTime,
    createdAt,
    updatedAt,
  ];
}
