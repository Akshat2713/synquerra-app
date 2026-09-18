part of 'schedule_overrides_bloc.dart';

abstract class ScheduleOverridesEvent extends Equatable {
  const ScheduleOverridesEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleOverridesLoadRequested extends ScheduleOverridesEvent {
  final String scheduleId;
  final String? startDate;
  final String? endDate;

  const ScheduleOverridesLoadRequested({
    required this.scheduleId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [scheduleId, startDate, endDate];
}

class ScheduleOverrideCreated extends ScheduleOverridesEvent {
  final String scheduleId;
  final Map<String, dynamic> overrideBody;

  const ScheduleOverrideCreated({
    required this.scheduleId,
    required this.overrideBody,
  });

  @override
  List<Object?> get props => [scheduleId, overrideBody];
}

class ScheduleOverrideUpdated extends ScheduleOverridesEvent {
  final String scheduleId;
  final String overrideId;
  final Map<String, dynamic> updateBody;

  const ScheduleOverrideUpdated({
    required this.scheduleId,
    required this.overrideId,
    required this.updateBody,
  });

  @override
  List<Object?> get props => [scheduleId, overrideId, updateBody];
}

class ScheduleOverrideDeleted extends ScheduleOverridesEvent {
  final String scheduleId;
  final String overrideId;

  const ScheduleOverrideDeleted({
    required this.scheduleId,
    required this.overrideId,
  });

  @override
  List<Object?> get props => [scheduleId, overrideId];
}
