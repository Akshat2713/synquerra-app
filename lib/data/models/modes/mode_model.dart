// data/models/mode/mode_model.dart

import '../../../domain/entities/modes/mode_entity.dart';

class ModeModel {
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

  const ModeModel({
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

  factory ModeModel.fromJson(Map<String, dynamic> json) => ModeModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    normalSendingInterval: json['normal_sending_interval'] as int,
    sosSendingInterval: json['sos_sending_interval'] as int,
    normalScanningInterval: json['normal_scanning_interval'] as int,
    airplaneInterval: json['airplane_interval'] as int,
    temperatureLimit: (json['temperature_limit'] as num).toDouble(),
    speedLimit: (json['speed_limit'] as num).toDouble(),
    lowbatLimit: json['lowbat_limit'] as int,
    isSystemMode: json['is_system_mode'] as bool,
    allowUserConditions: json['allow_user_conditions'] as bool,
    priority: json['priority'] as int,
    watchTime: json['watch_time'] as int,
    createdAt: json['created_at'] as String,
    updatedAt: json['updated_at'] as String,
  );

  ModeEntity toEntity() => ModeEntity(
    id: id,
    name: name,
    description: description,
    normalSendingInterval: normalSendingInterval,
    sosSendingInterval: sosSendingInterval,
    normalScanningInterval: normalScanningInterval,
    airplaneInterval: airplaneInterval,
    temperatureLimit: temperatureLimit,
    speedLimit: speedLimit,
    lowbatLimit: lowbatLimit,
    isSystemMode: isSystemMode,
    allowUserConditions: allowUserConditions,
    priority: priority,
    watchTime: watchTime,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
