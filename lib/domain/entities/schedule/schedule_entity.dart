import 'package:equatable/equatable.dart';

class ScheduleEntity extends Equatable {
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

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScheduleEntity({
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

  @override
  List<Object?> get props => [
    id,
    targetUserId,
    deviceId,
    geofenceId,
    title,
    description,
    startTime,
    endTime,
    timezone,
    recurrenceType,
    daysOfWeek,
    customDates,
    startDate,
    endDate,
    crossesMidnight,
    priority,
    isActive,
    arrivalGraceMins,
    departureBufferMins,
    minimumStayMins,
    createdAt,
    updatedAt,
  ];
}
