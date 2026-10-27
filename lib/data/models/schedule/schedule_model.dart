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
    final grace = json['graceConfig'] as Map<String, dynamic>? ?? {};
    final targetUser = json['targetUser'] as Map<String, dynamic>? ?? {};
    final device = json['device'] as Map<String, dynamic>? ?? {};
    final geofence = json['geofence'] as Map<String, dynamic>? ?? {};

    return ScheduleModel(
      id: json['id'] as String? ?? '',
      targetUserId: targetUser['userId'] as String? ?? '',
      deviceId: device['deviceId'] as String? ?? '',
      geofenceId: geofence['geofenceId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      recurrenceType: json['recurrenceType'] as String? ?? 'WEEKLY',
      daysOfWeek:
          (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      customDates:
          (json['customDates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String?,
      crossesMidnight: json['crossesMidnight'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'MEDIUM',
      isActive: json['isActive'] as bool? ?? true,
      arrivalGraceMins: (grace['entryGraceMinutes'] as num?)?.toInt() ?? 10,
      departureBufferMins: (grace['exitGraceMinutes'] as num?)?.toInt() ?? 5,
      minimumStayMins: (grace['minimumStayMinutes'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
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
