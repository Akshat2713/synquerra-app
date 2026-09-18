import 'package:equatable/equatable.dart';
import 'schedule_entity.dart';
import 'schedule_override_entity.dart';

class EffectiveScheduleEntity extends Equatable {
  final String date;
  final String scheduleId;
  final bool isEffective;
  final String status;
  final ScheduleEntity? baseSchedule;
  final ScheduleOverrideEntity? override;

  const EffectiveScheduleEntity({
    required this.date,
    required this.scheduleId,
    required this.isEffective,
    required this.status,
    this.baseSchedule,
    this.override,
  });

  List<Object?> get props => [
    date,
    scheduleId,
    isEffective,
    status,
    baseSchedule,
    override,
  ];
}
