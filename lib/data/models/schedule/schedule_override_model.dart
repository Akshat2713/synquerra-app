import '../../../domain/entities/schedule/schedule_override_entity.dart';

class ScheduleOverrideModel {
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
  final String? createdAt;
  final String? updatedAt;

  const ScheduleOverrideModel({
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

  factory ScheduleOverrideModel.fromJson(Map<String, dynamic> json) =>
      ScheduleOverrideModel(
        id: json['id'] as String? ?? json['_id'] as String? ?? '',
        scheduleId: json['schedule_id'] as String? ?? '',
        targetUserId: json['target_user_id'] as String? ?? '',
        deviceId: json['device_id'] as String? ?? '',
        date: json['date'] as String? ?? '',
        overrideType: json['override_type'] as String? ?? '',
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
        geofenceId: json['geofence_id'] as String?,
        reason: json['reason'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  ScheduleOverrideEntity toEntity() => ScheduleOverrideEntity(
    id: id,
    scheduleId: scheduleId,
    targetUserId: targetUserId,
    deviceId: deviceId,
    date: date,
    overrideType: overrideType,
    startTime: startTime,
    endTime: endTime,
    geofenceId: geofenceId,
    reason: reason,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
  );
}
