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

  factory ModeModel.fromJson(Map<String, dynamic> json) => ModeModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    normalSendingInterval: json['normal_sending_interval'] as int? ?? 0,
    sosSendingInterval: json['sos_sending_interval'] as int? ?? 0,
    normalScanningInterval: json['normal_scanning_interval'] as int? ?? 0,
    airplaneInterval: json['airplane_interval'] as int? ?? 0,
    temperatureLimit: (json['temperature_limit'] as num?)?.toDouble() ?? 0,
    speedLimit: (json['speed_limit'] as num?)?.toDouble() ?? 0,
    lowbatLimit: json['lowbat_limit'] as int? ?? 0,
    categories:
        (json['categories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    note: json['note'] as String? ?? '',
    priority: json['priority'] as int? ?? 0,
    reconfirmationTime: json['reconfirmation_time'] as int? ?? 0,
    airplaneMode: json['airplane_mode'] as bool? ?? false,
    ambientListeningStatus:
        json['ambient_listening_status'] as String? ?? 'Stop',
    ledStatus: json['led_status'] as bool? ?? false,
    isActive: json['is_active'] as bool? ?? false,
    isDefault: json['is_default'] as bool? ?? false,
    createdAt: json['created_at'] as String? ?? '',
    updatedAt: json['updated_at'] as String? ?? '',
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
    categories: categories,
    note: note,
    priority: priority,
    reconfirmationTime: reconfirmationTime,
    airplaneMode: airplaneMode,
    ambientListeningStatus: ambientListeningStatus,
    ledStatus: ledStatus,
    isActive: isActive,
    isDefault: isDefault,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
