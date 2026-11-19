import '../../../domain/entities/schedule/schedule_entity.dart';

class ScheduleModel {
  final String id;
  final String targetUserId;
  final String deviceId;
  final String geofenceId;
  final String title;
  final String? description;
  final String startTime;
  final String endTime;
  final String timezone;
  final String recurrenceType;
  final List<int> daysOfWeek;
  final List<String> customDates;
  final String startDate;
  final String? endDate;
  final bool crossesMidnight;
  final String priority;
  final bool isActive;
  final int arrivalGraceMins;
  final int departureBufferMins;
  final int? minimumStayMins;
  final String? createdAt;
  final String? updatedAt;

  const ScheduleModel({
    required this.id,
    required this.targetUserId,
    required this.deviceId,
    required this.geofenceId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.timezone,
    required this.recurrenceType,
    required this.daysOfWeek,
    required this.customDates,
    required this.startDate,
    this.endDate,
    required this.crossesMidnight,
    required this.priority,
    required this.isActive,
    required this.arrivalGraceMins,
    required this.departureBufferMins,
    this.minimumStayMins,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final grace =
        (json['grace_config'] ?? json['graceConfig'])
            as Map<String, dynamic>? ??
        {};
    final targetUser =
        (json['target_user'] ?? json['targetUser']) as Map<String, dynamic>? ??
        {};
    final device = (json['device']) as Map<String, dynamic>? ?? {};
    final geofence = (json['geofence']) as Map<String, dynamic>? ?? {};

    return ScheduleModel(
      id: (json['id'] ?? '') as String,
      targetUserId:
          (targetUser['user_id'] ?? targetUser['userId'] ?? '') as String,
      deviceId: (device['device_id'] ?? device['deviceId'] ?? '') as String,
      geofenceId:
          (geofence['geofence_id'] ?? geofence['geofenceId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      startTime: (json['start_time'] ?? json['startTime'] ?? '') as String,
      endTime: (json['end_time'] ?? json['endTime'] ?? '') as String,
      timezone: (json['timezone'] ?? 'Asia/Kolkata') as String,
      recurrenceType:
          (json['recurrence_type'] ?? json['recurrenceType'] ?? 'WEEKLY')
              as String,
      daysOfWeek:
          ((json['days_of_week'] ?? json['daysOfWeek']) as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      customDates:
          ((json['custom_dates'] ?? json['customDates']) as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      startDate: (json['start_date'] ?? json['startDate'] ?? '') as String,
      endDate: (json['end_date'] ?? json['endDate']) as String?,
      crossesMidnight:
          (json['crosses_midnight'] ?? json['crossesMidnight'] ?? false)
              as bool,
      priority: (json['priority'] ?? 'MEDIUM') as String,
      isActive: (json['is_active'] ?? json['isActive'] ?? true) as bool,
      arrivalGraceMins:
          ((grace['arrival_grace_mins'] ?? grace['entryGraceMinutes']) as num?)
              ?.toInt() ??
          10,
      departureBufferMins:
          ((grace['departure_buffer_mins'] ?? grace['exitGraceMinutes'])
                  as num?)
              ?.toInt() ??
          5,
      minimumStayMins:
          ((grace['minimum_stay_mins'] ?? grace['minimumStayMinutes']) as num?)
              ?.toInt(),
      createdAt: (json['created_at'] ?? json['createdAt']) as String?,
      updatedAt: (json['updated_at'] ?? json['updatedAt']) as String?,
    );
  }

  ScheduleEntity toEntity() => ScheduleEntity(
    id: id,
    targetUserId: targetUserId,
    deviceId: deviceId,
    geofenceId: geofenceId,
    title: title,
    description: description,
    startTime: startTime,
    endTime: endTime,
    timezone: timezone,
    recurrenceType: recurrenceType,
    daysOfWeek: daysOfWeek,
    customDates: customDates,
    startDate: startDate,
    endDate: endDate,
    crossesMidnight: crossesMidnight,
    priority: priority,
    isActive: isActive,
    arrivalGraceMins: arrivalGraceMins,
    departureBufferMins: departureBufferMins,
    minimumStayMins: minimumStayMins,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
  );
}
