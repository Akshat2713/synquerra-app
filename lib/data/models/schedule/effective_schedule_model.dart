import '../../../domain/entities/schedule/effective_schedule_entity.dart';
import 'schedule_model.dart';
import 'schedule_override_model.dart';

class EffectiveScheduleModel {
  final String date;
  final String scheduleId;
  final bool isEffective;
  final String status;
  final ScheduleModel? baseSchedule;
  final ScheduleOverrideModel? override;

  const EffectiveScheduleModel({
    required this.date,
    required this.scheduleId,
    required this.isEffective,
    required this.status,
    this.baseSchedule,
    this.override,
  });

  factory EffectiveScheduleModel.fromJson(Map<String, dynamic> json) {
    return EffectiveScheduleModel(
      date: json['date'] as String? ?? '',
      scheduleId: json['schedule_id'] as String? ?? '',
      isEffective: json['is_effective'] as bool? ?? false,
      status: json['status'] as String? ?? 'NOT_SCHEDULED',
      baseSchedule: json['base_schedule'] != null
          ? ScheduleModel.fromJson(
              json['base_schedule'] as Map<String, dynamic>,
            )
          : null,
      override: json['override'] != null
          ? ScheduleOverrideModel.fromJson(
              json['override'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  EffectiveScheduleEntity toEntity() => EffectiveScheduleEntity(
    date: date,
    scheduleId: scheduleId,
    isEffective: isEffective,
    status: status,
    baseSchedule: baseSchedule?.toEntity(),
    override: override?.toEntity(),
  );
}
