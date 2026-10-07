part of 'mode_condition_bloc.dart';

abstract class ModeConditionEvent extends Equatable {
  const ModeConditionEvent();
  @override
  List<Object?> get props => [];
}

/// Load all conditions (geofence + device geofence) for a device.
class ModeConditionLoad extends ModeConditionEvent {
  final String deviceId;
  const ModeConditionLoad(this.deviceId);
  @override
  List<Object?> get props => [deviceId];
}

/// Load modes for the dropdown.
class ModeConditionLoadModes extends ModeConditionEvent {
  final String category;
  const ModeConditionLoadModes(this.category);
  @override
  List<Object?> get props => [category];
}

class ModeConditionCreate extends ModeConditionEvent {
  final String deviceId;
  final String modeId;
  final String conditionType;
  final bool enabled;
  final Map<String, dynamic> config;

  const ModeConditionCreate({
    required this.deviceId,
    required this.modeId,
    required this.conditionType,
    required this.config,
    this.enabled = true,
  });

  @override
  List<Object?> get props => [deviceId, modeId, conditionType, enabled, config];
}

class ModeConditionUpdate extends ModeConditionEvent {
  final String conditionId;
  final String deviceId;
  final String modeId;
  final String conditionType;
  final bool enabled;
  final Map<String, dynamic> config;

  const ModeConditionUpdate({
    required this.conditionId,
    required this.deviceId,
    required this.modeId,
    required this.conditionType,
    required this.config,
    this.enabled = true,
  });

  @override
  List<Object?> get props => [
    conditionId,
    deviceId,
    modeId,
    conditionType,
    enabled,
    config,
  ];
}

class ModeConditionDelete extends ModeConditionEvent {
  final String deviceId; // needed to reload the list afterwards
  final String conditionId;
  const ModeConditionDelete({
    required this.deviceId,
    required this.conditionId,
  });
  @override
  List<Object?> get props => [deviceId, conditionId];
}
