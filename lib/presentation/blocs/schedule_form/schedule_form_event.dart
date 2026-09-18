part of 'schedule_form_bloc.dart';

abstract class ScheduleFormEvent extends Equatable {
  const ScheduleFormEvent();
  @override
  List<Object?> get props => [];
}

/// Loads an existing schedule for edit mode and auto-fetches its geofences.
class ScheduleFormEditRequested extends ScheduleFormEvent {
  final String scheduleId;
  const ScheduleFormEditRequested(this.scheduleId);
  @override
  List<Object?> get props => [scheduleId];
}

/// Fired when the device dropdown changes (including cleared to null).
class ScheduleFormDeviceChanged extends ScheduleFormEvent {
  final String? deviceId;
  const ScheduleFormDeviceChanged(this.deviceId);
  @override
  List<Object?> get props => [deviceId];
}

class ScheduleFormCreateSubmitted extends ScheduleFormEvent {
  final Map<String, dynamic> body;
  const ScheduleFormCreateSubmitted(this.body);
  @override
  List<Object?> get props => [body];
}

class ScheduleFormUpdateSubmitted extends ScheduleFormEvent {
  final String scheduleId;
  final Map<String, dynamic> body;
  const ScheduleFormUpdateSubmitted({
    required this.scheduleId,
    required this.body,
  });
  @override
  List<Object?> get props => [scheduleId, body];
}

/// Resets the bloc back to a blank create-mode state (e.g. bloc reused
/// across nav pushes rather than re-provided per screen).
class ScheduleFormReset extends ScheduleFormEvent {
  const ScheduleFormReset();
}
