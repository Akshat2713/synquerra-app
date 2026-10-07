import '../../../domain/entities/geofence_mode/mode_condition_entity.dart';

class ModeSummaryModel {
  final String id;
  final String modeId;
  final String name;
  final String? description;
  final int? priority;

  const ModeSummaryModel({
    required this.id,
    required this.modeId,
    required this.name,
    this.description,
    this.priority,
  });

  factory ModeSummaryModel.fromJson(Map<String, dynamic> json) {
    return ModeSummaryModel(
      id: (json['id'] ?? '').toString(),
      modeId: (json['modeId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
    );
  }

  ModeSummaryEntity toEntity() => ModeSummaryEntity(
    id: id,
    modeId: modeId,
    name: name,
    description: description,
    priority: priority,
  );
}

class ModeConditionModel {
  final String id;
  final String modeId;
  final String deviceId;
  final String conditionType;
  final Map<String, dynamic> config;
  final bool enabled;
  final ModeSummaryModel? mode;
  final String? createdAt;
  final String? updatedAt;

  const ModeConditionModel({
    required this.id,
    required this.modeId,
    required this.deviceId,
    required this.conditionType,
    this.config = const {},
    required this.enabled,
    this.mode,
    this.createdAt,
    this.updatedAt,
  });

  factory ModeConditionModel.fromJson(Map<String, dynamic> json) {
    final modeJson = json['mode'] as Map<String, dynamic>?;
    final configJson = json['config'];

    return ModeConditionModel(
      id: (json['id'] ?? '').toString(),
      modeId: (json['modeId'] ?? '').toString(),
      deviceId: (json['deviceId'] ?? '').toString(),
      conditionType: (json['conditionType'] ?? '').toString(),
      config: configJson is Map
          ? Map<String, dynamic>.from(configJson)
          : const {},
      enabled: (json['enabled'] as bool?) ?? false,
      mode: modeJson != null ? ModeSummaryModel.fromJson(modeJson) : null,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  ModeConditionEntity toEntity() => ModeConditionEntity(
    id: id,
    modeId: modeId,
    deviceId: deviceId,
    conditionType: conditionType,
    config: config,
    enabled: enabled,
    mode: mode?.toEntity(),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
