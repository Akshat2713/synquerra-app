import 'package:equatable/equatable.dart';

class ModeSummaryEntity extends Equatable {
  final String id;
  final String modeId;
  final String name;
  final String? description;
  final int? priority;

  const ModeSummaryEntity({
    required this.id,
    required this.modeId,
    required this.name,
    this.description,
    this.priority,
  });

  String get displayDescription => (description?.trim().isNotEmpty ?? false)
      ? description!
      : 'No description available';

  @override
  List<Object?> get props => [id, modeId, name, description, priority];
}

class ModeConditionEntity extends Equatable {
  final String id;
  final String modeId;
  final String deviceId;
  final String conditionType; // speed | battery | geofence
  final Map<String, dynamic> config;
  final bool enabled;
  final ModeSummaryEntity? mode;
  final String? createdAt;
  final String? updatedAt;

  const ModeConditionEntity({
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

  bool get isGeofence => conditionType == 'geofence';
  bool get isSpeed => conditionType == 'speed';
  bool get isBattery => conditionType == 'battery';

  /// Geofence config helper
  String? get geofenceId => config['geofence_id']?.toString();
  bool get isDeviceGeofence => conditionType == 'device_geofence';
  String? get geofenceValue => config['geofence_value']?.toString();
  int? get conditionGroup => (config['condition_group'] as num?)?.toInt();

  @override
  List<Object?> get props => [
    id,
    modeId,
    deviceId,
    conditionType,
    config,
    enabled,
    mode,
    createdAt,
    updatedAt,
  ];
}
