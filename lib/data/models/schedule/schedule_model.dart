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
  final bool alertOnAbsence;
  final bool alertOnLateArrival;
  final bool alertOnEarlyDeparture;
  final bool alertOnEarlyEntry;
  final bool alertOnReentry;
  final bool sendPushNotification;
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
    required this.alertOnAbsence,
    required this.alertOnLateArrival,
    required this.alertOnEarlyDeparture,
    required this.alertOnEarlyEntry,
    required this.alertOnReentry,
    required this.sendPushNotification,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final graceConfig = json['grace_config'] as Map<String, dynamic>? ?? {};
    final alertSettings = json['alert_settings'] as Map<String, dynamic>? ?? {};
    final targetUser = json['target_user'] as Map<String, dynamic>? ?? {};
    final device = json['device'] as Map<String, dynamic>? ?? {};
    final geofence = json['geofence'] as Map<String, dynamic>? ?? {};

    return ScheduleModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      // These three IDs live inside nested objects in the API response,
      // not at the top level — pulling from the nested maps fixes the
      // empty-string bug that broke geofence fetching downstream.
      targetUserId: targetUser['user_id'] as String? ?? '',
      deviceId: device['device_id'] as String? ?? '',
      geofenceId: geofence['geofence_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      recurrenceType: json['recurrence_type'] as String? ?? 'WEEKLY',
      daysOfWeek:
          (json['days_of_week'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      customDates:
          (json['custom_dates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String?,
      crossesMidnight: json['crosses_midnight'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'MEDIUM',
      isActive: json['is_active'] as bool? ?? true,
      arrivalGraceMins:
          (graceConfig['arrival_grace_mins'] as num?)?.toInt() ?? 10,
      departureBufferMins:
          (graceConfig['departure_buffer_mins'] as num?)?.toInt() ?? 5,
      minimumStayMins: (graceConfig['minimum_stay_mins'] as num?)?.toInt(),
      alertOnAbsence: alertSettings['alert_on_absence'] as bool? ?? true,
      alertOnLateArrival:
          alertSettings['alert_on_late_arrival'] as bool? ?? true,
      alertOnEarlyDeparture:
          alertSettings['alert_on_early_departure'] as bool? ?? true,
      alertOnEarlyEntry:
          alertSettings['alert_on_early_entry'] as bool? ?? false,
      alertOnReentry: alertSettings['alert_on_reentry'] as bool? ?? false,
      sendPushNotification:
          alertSettings['send_push_notification'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
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
    alertOnAbsence: alertOnAbsence,
    alertOnLateArrival: alertOnLateArrival,
    alertOnEarlyDeparture: alertOnEarlyDeparture,
    alertOnEarlyEntry: alertOnEarlyEntry,
    alertOnReentry: alertOnReentry,
    sendPushNotification: sendPushNotification,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
  );
}
