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
  final List<String> categories;
  final String note;
  final int priority;
  final int reconfirmationTime;
  final bool airplaneMode;
  final String ambientListeningStatus;
  final bool ledStatus;
  final bool isActive;
  final bool isDefault;
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
    required this.categories,
    required this.note,
    required this.priority,
    required this.reconfirmationTime,
    required this.airplaneMode,
    required this.ambientListeningStatus,
    required this.ledStatus,
    required this.isActive,
    required this.isDefault,
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
    categories,
    note,
    priority,
    reconfirmationTime,
    airplaneMode,
    ambientListeningStatus,
    ledStatus,
    isActive,
    isDefault,
    createdAt,
    updatedAt,
  ];
}
