import 'package:equatable/equatable.dart';

class ScheduleOverrideEntity extends Equatable {
  final String id;
  final String scheduleId;
  final String targetUserId;
  final String deviceId;
  final String date;
  final String overrideType;
  final String? startTime;
  final String? endTime;
  final String? geofenceId;
  final String? reason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScheduleOverrideEntity({
    required this.id,
    required this.scheduleId,
    required this.targetUserId,
    required this.deviceId,
    required this.date,
    required this.overrideType,
    this.startTime,
    this.endTime,
    this.geofenceId,
    this.reason,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    scheduleId,
    targetUserId,
    deviceId,
    date,
    overrideType,
    startTime,
    endTime,
    geofenceId,
    reason,
    createdAt,
    updatedAt,
  ];
}
